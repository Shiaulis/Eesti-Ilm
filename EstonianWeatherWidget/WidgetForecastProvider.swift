//
//  WidgetForecastProvider.swift
//  EstonianWeatherWidgetExtension
//
//  Created by Andrius Shiaulis on 11.10.2020.
//

import Combine
import NetworkModule
import WeatherKit
import WeatherLocale
import WidgetKit

struct ForecastEntry: TimelineEntry {
    let date: Date
    let displayItems: [ForecastDisplayItem]

    init(displayItems: [ForecastDisplayItem] = [], date: Date) {
        self.displayItems = displayItems
        self.date = date
    }

    static let test = ForecastEntry(displayItems: [.test1, .test3, .test2, .test2], date: .now)
}

final class WidgetForecastProvider: TimelineProvider {
    private let model: WeatherModel
    private var lastFetchedDisplayItems: [ForecastDisplayItem] = []

    init() {
        let locale = Locale.current
        let weatherLocale = WeatherLocale(locale: locale) ?? .english
        self.model = NetworkWeatherModel(
            weatherLocale: weatherLocale,
            responseParser: SWXMLResponseParser(locale: locale),
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
