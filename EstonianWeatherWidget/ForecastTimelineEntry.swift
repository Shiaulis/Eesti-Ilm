//
//  ForecastTimelineEntry.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//

import Foundation
import WeatherCore
import WidgetKit

struct ForecastTimelineEntry: TimelineEntry, Sendable {
    let date: Date
    let forecasts: [ForecastConfiguration]
    let isPlaceholder: Bool

    init(date: Date, forecasts: [ForecastConfiguration], isPlaceholder: Bool = false) {
        self.date = date
        self.forecasts = forecasts
        self.isPlaceholder = isPlaceholder
    }
}

extension ForecastTimelineEntry {
    static var preview: ForecastTimelineEntry {
        ForecastTimelineEntry(date: .now, forecasts: .previewSamples)
    }

    static var placeholder: ForecastTimelineEntry {
        ForecastTimelineEntry(date: .now, forecasts: .previewSamples, isPlaceholder: true)
    }

    static var empty: ForecastTimelineEntry {
        ForecastTimelineEntry(date: .now, forecasts: [])
    }
}

extension [ForecastConfiguration] {
    static var previewSamples: [ForecastConfiguration] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let phenomena = ["Few clouds", "Clear", "Moderate rain", "Cloudy with clear spells"]
        let ranges = [
            TemperatureRange(minimum: 2, maximum: 7),
            TemperatureRange(minimum: 4, maximum: 10),
            TemperatureRange(minimum: 1, maximum: 5),
            TemperatureRange(minimum: 3, maximum: 8),
        ]

        return (0 ..< 4).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                return nil
            }

            let dayPart = DayPartConfiguration(
                phenomenon: phenomena[offset],
                temperatureRange: ranges[offset],
                description: ""
            )
            return ForecastConfiguration(
                date: date,
                night: dayPart,
                day: dayPart
            )
        }
    }
}
