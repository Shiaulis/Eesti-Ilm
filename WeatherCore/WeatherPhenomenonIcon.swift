//
//  WeatherPhenomenonIcon.swift
//  WeatherCore
//

import Foundation

/// Maps the phenomenon text of the ilmateenistus.ee forecast to an SF Symbol name.
///
/// The app and the widget share this mapping so the same weather shows the same symbol everywhere.
public enum WeatherPhenomenonIcon {
    /// The symbol used when the phenomenon is blank or not recognized.
    public static let defaultSymbolName = "cloud"

    /// Returns the SF Symbol name for a phenomenon. Matching ignores case and surrounding whitespace.
    public static func symbolName(for phenomenon: String) -> String {
        let normalized = phenomenon
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return self.symbolMap[normalized] ?? self.defaultSymbolName
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
        "light snow": "cloud.snow",
        "moderate snow": "cloud.snow",
        "heavy snow": "cloud.snow",
        "light snowfall": "cloud.snow",
        "moderate snowfall": "cloud.snow",
        "heavy snowfall": "cloud.snow",
        "snowstorm": "cloud.snow",
        "drifting snow": "cloud.snow",
        "light shower": "cloud.drizzle",
        "moderate shower": "cloud.rain",
        "heavy shower": "cloud.heavyrain",
        "light rain": "cloud.drizzle",
        "moderate rain": "cloud.rain",
        "heavy rain": "cloud.heavyrain",
        "light sleet": "cloud.sleet",
        "moderate sleet": "cloud.sleet",
        "risk of glaze": "thermometer.snowflake",
        "hail": "cloud.hail",
        "mist": "cloud.fog",
        "fog": "cloud.fog",
        "thunder": "cloud.bolt",
        "thunderstorm": "cloud.bolt",
    ]
}
