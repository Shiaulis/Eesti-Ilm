//
//  ForecastTimelineProvider.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//

import Foundation
import WeatherCore
import WidgetKit

struct ForecastTimelineProvider: TimelineProvider {
    private static let successRefreshInterval: TimeInterval = 60 * 60
    private static let failureRetryInterval: TimeInterval = 15 * 60

    private let fetchForecasts: @Sendable () async throws -> [ForecastConfiguration]

    init(fetchForecasts: @escaping @Sendable () async throws -> [ForecastConfiguration] = {
        try await WeatherService().getForecasts(for: .current)
    }) {
        self.fetchForecasts = fetchForecasts
    }

    func placeholder(in context: Context) -> ForecastTimelineEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ForecastTimelineEntry) -> Void) {
        if context.isPreview {
            completion(.preview)
            return
        }

        let fetchForecasts = self.fetchForecasts
        nonisolated(unsafe) let completion = completion
        Task {
            do {
                let forecasts = try await fetchForecasts()
                completion(ForecastTimelineEntry(date: .now, forecasts: forecasts))
            }
            catch {
                completion(.empty)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastTimelineEntry>) -> Void) {
        let fetchForecasts = self.fetchForecasts
        nonisolated(unsafe) let completion = completion
        Task {
            do {
                let forecasts = try await fetchForecasts()
                let now = Date.now
                let entry = ForecastTimelineEntry(date: now, forecasts: forecasts)
                let nextUpdate = now.addingTimeInterval(Self.successRefreshInterval)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            }
            catch {
                let now = Date.now
                let entry = ForecastTimelineEntry(date: now, forecasts: [])
                let nextRetry = now.addingTimeInterval(Self.failureRetryInterval)
                completion(Timeline(entries: [entry], policy: .after(nextRetry)))
            }
        }
    }
}
