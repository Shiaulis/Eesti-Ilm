//
//  WeatherPhenomenonIcon.swift
//  WeatherCore
//

import Foundation

/// Maps the phenomenon text of the ilmateenistus.ee forecast to an SF Symbol name and localization key.
///
/// The app and the widget share this mapping so the same weather shows the same symbol and label everywhere.
public enum WeatherPhenomenonIcon {
    /// The symbol used when the phenomenon is blank or not recognized.
    public static let defaultSymbolName = "cloud"

    /// Returns the SF Symbol name for a phenomenon. Matching ignores case and surrounding whitespace.
    public static func symbolName(for phenomenon: String) -> String {
        let normalized = self.normalize(phenomenon)
        return self.phenomenonMap[normalized]?.symbolName ?? self.defaultSymbolName
    }

    /// Returns the localization key for a known phenomenon, or the raw phenomenon string as fallback.
    ///
    /// Matching ignores case and surrounding whitespace.
    public static func localizationKey(for phenomenon: String) -> String {
        let normalized = self.normalize(phenomenon)
        return self.phenomenonMap[normalized]?.localizationKey ?? phenomenon
    }

    /// Returns the phenomenon name in the user's language, or the raw phenomenon string if it is not known.
    ///
    /// The feed sends phenomena in English in every language. The translations live in the String Catalog
    /// of the calling app or widget (`Bundle.main`), not in this framework.
    public static func localizedName(for phenomenon: String) -> String {
        String(localized: String.LocalizationValue(self.localizationKey(for: phenomenon)), bundle: .main)
    }

    private static func normalize(_ phenomenon: String) -> String {
        phenomenon
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static let phenomenonMap: [String: (symbolName: String, localizationKey: String)] = [
        "clear": ("sun.max", "Clear"),
        "sunny": ("sun.max", "Sunny"),
        "few clouds": ("cloud.sun", "Few clouds"),
        "variable clouds": ("cloud.sun", "Variable clouds"),
        "cloudy with clear spells": ("cloud.sun", "Cloudy with clear spells"),
        "partly cloudy": ("cloud.sun", "Partly cloudy"),
        "cloudy": ("smoke", "Cloudy"),
        "overcast": ("smoke", "Overcast"),
        "light snow shower": ("cloud.snow", "Light snow shower"),
        "moderate snow shower": ("cloud.snow", "Moderate snow shower"),
        "heavy snow shower": ("cloud.snow", "Heavy snow shower"),
        "light snow": ("cloud.snow", "Light snow"),
        "moderate snow": ("cloud.snow", "Moderate snow"),
        "heavy snow": ("cloud.snow", "Heavy snow"),
        "light snowfall": ("cloud.snow", "Light snowfall"),
        "moderate snowfall": ("cloud.snow", "Moderate snowfall"),
        "heavy snowfall": ("cloud.snow", "Heavy snowfall"),
        "snowstorm": ("cloud.snow", "Snowstorm"),
        "drifting snow": ("cloud.snow", "Drifting snow"),
        "light shower": ("cloud.drizzle", "Light shower"),
        "moderate shower": ("cloud.rain", "Moderate shower"),
        "heavy shower": ("cloud.heavyrain", "Heavy shower"),
        "light rain": ("cloud.drizzle", "Light rain"),
        "moderate rain": ("cloud.rain", "Moderate rain"),
        "heavy rain": ("cloud.heavyrain", "Heavy rain"),
        "light sleet": ("cloud.sleet", "Light sleet"),
        "moderate sleet": ("cloud.sleet", "Moderate sleet"),
        "risk of glaze": ("thermometer.snowflake", "Risk of glaze"),
        "hail": ("cloud.hail", "Hail"),
        "mist": ("cloud.fog", "Mist"),
        "fog": ("cloud.fog", "Fog"),
        "thunder": ("cloud.bolt", "Thunder"),
        "thunderstorm": ("cloud.bolt", "Thunderstorm"),
    ]
}
