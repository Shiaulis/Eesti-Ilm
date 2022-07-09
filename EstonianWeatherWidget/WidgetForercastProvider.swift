//
//  WidgetForercastProvider.swift
//  EstonianWeatherWidgetExtension
//
//  Created by Andrius Shiaulis on 11.10.2020.
//

import WidgetKit
import Combine
import WeatherKit
import NetworkModule

struct ForecastEntry: TimelineEntry {
    let date: Date
    let displayItems: [ForecastDisplayItem]

    init(displayItems: [ForecastDisplayItem] = [], date: Date) {
        self.displayItems = displayItems
        self.date = date
    }

    static let test: ForecastEntry = .init(displayItems: [.test1, .test3, .test2, .test2], date: .now)
}

final class WidgetForercastProvider: TimelineProvider {

    private let model: WeatherModel
    private var lastFetchedDisplayItems: [ForecastDisplayItem] = []

    private var disposables: Set<AnyCancellable> = []

    init() {
        self.model = NetwokWeatherModel(
            weatherLocale: .english,
            responseParser: SWXMLResponseParser(logger: .init(subsystem: .widget, category: .weatherModel)),
            networkClient: URLSessionNetworkClient()
        )
    }

    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(displayItems: [.test1, .test2, .test3], date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> Void) {
        let entry = ForecastEntry(displayItems: self.lastFetchedDisplayItems, date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastEntry>) -> Void) {
        requestAndMapForecasts { entry in
            completion(.init(entries: [entry], policy: .atEnd))
        }
    }

    private func requestAndMapForecasts(completion: @escaping (ForecastEntry) -> Void) {
        Task {
            do {
                self.lastFetchedDisplayItems = try await self.model.forecasts()
                completion(.init(displayItems: self.lastFetchedDisplayItems, date: .now))
            }
            catch {
                completion(.init(displayItems: [], date: .now))
            }
        }
    }

}
