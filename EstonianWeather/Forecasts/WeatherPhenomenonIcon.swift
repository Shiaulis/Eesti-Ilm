//
//  WeatherPhenomenonIcon.swift
//  EstonianWeather
//

import Foundation

nonisolated enum WeatherPhenomenonIcon {
    static func symbolName(for phenomenon: String) -> String? {
        let normalized = phenomenon
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalized.isEmpty else {
            return nil
        }

        return self.symbolMap[normalized]
    }

    private static let symbolMap: [String: String] = [
        "clear": "sun.max",
        "sunny": "sun.max",
        "few clouds": "cloud.sun",
        "variable clouds": "cloud.sun",
        "cloudy with clear spells": "cloud.sun",
        "partly cloudy": "cloud.sun",
        "cloudy": "smoke",
        "overcast": "smoke",
        "light snow shower": "cloud.snow",
        "moderate snow shower": "cloud.snow",
        "heavy snow shower": "cloud.snow",
        "light shower": "cloud.drizzle",
        "moderate shower": "cloud.rain",
        "heavy shower": "cloud.heavyrain",
        "light rain": "cloud.drizzle",
        "moderate rain": "cloud.rain",
        "heavy rain": "cloud.heavyrain",
        "risk of glaze": "thermometer.snowflake",
        "light sleet": "cloud.sleet",
        "moderate sleet": "cloud.sleet",
        "light snow": "cloud.snow",
        "light snowfall": "cloud.snow",
        "moderate snowfall": "cloud.snow",
        "heavy snowfall": "cloud.snow",
        "snowstorm": "cloud.snow",
        "drifting snow": "cloud.snow",
        "hail": "cloud.hail",
        "mist": "cloud.fog",
        "fog": "cloud.fog",
        "thunder": "cloud.bolt",
        "thunderstorm": "cloud.bolt",
    ]
}
