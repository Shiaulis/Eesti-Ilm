//
//  ForecastConfigurationConverter.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 12.07.2025.
//

import Foundation

// MARK: - Conversion Extensions
extension ForecastConfiguration {
    /// Creates a ForecastConfiguration from a server Forecast model
    init(from forecast: Forecast, dateFormatter: ForecastDateFormatter = ForecastDateFormatter()) throws {
        let parsedDate = try dateFormatter.date(from: forecast.date)
        
        self.init(
            date: parsedDate,
            night: DayPartConfiguration(from: forecast.night),
            day: DayPartConfiguration(from: forecast.day)
        )
    }
}

extension DayPartConfiguration {
    /// Creates a DayPartConfiguration from a server DayPart model
    init(from dayPart: DayPart) {
        self.init(
            phenomenon: dayPart.phenomenon,
            temperatureRange: TemperatureRange(
                minimum: dayPart.minimalTemperature,
                maximum: dayPart.maximalTemperature
            ),
            description: dayPart.text,
            places: dayPart.places?.map(PlaceConfiguration.init) ?? [],
            winds: dayPart.winds?.map(WindConfiguration.init) ?? [],
            seaCondition: dayPart.sea,
            lakeCondition: dayPart.lake
        )
    }
}

extension PlaceConfiguration {
    /// Creates a PlaceConfiguration from a server Place model
    init(from place: Place) {
        let temperatureRange: TemperatureRange?
        
        if let minTemp = place.minimalTemperature, let maxTemp = place.maximalTemperature {
            temperatureRange = TemperatureRange(minimum: minTemp, maximum: maxTemp)
        } else {
            temperatureRange = nil
        }
        
        self.init(
            name: place.name,
            phenomenon: place.phenomenon,
            temperatureRange: temperatureRange
        )
    }
}

extension WindConfiguration {
    /// Creates a WindConfiguration from a server Wind model
    init(from wind: Wind) {
        self.init(
            name: wind.name,
            direction: wind.direction,
            speedRange: SpeedRange(
                minimum: wind.minimalSpeed,
                maximum: wind.maximalSpeed
            ),
            gustDescription: wind.gust?.isEmpty == false ? wind.gust : nil
        )
    }
}

// MARK: - Batch Conversion
extension Array where Element == ForecastConfiguration {
    /// Creates an array of ForecastConfiguration from server Forecast models
    static func from(
        forecasts: [Forecast], 
        dateFormatter: ForecastDateFormatter = ForecastDateFormatter()
    ) throws -> [ForecastConfiguration] {
        try forecasts.map { forecast in
            try ForecastConfiguration(from: forecast, dateFormatter: dateFormatter)
        }
    }
}
