//
//  WeatherPhenomenonIconTests.swift
//  WeatherCoreTests
//

import Testing
@testable import WeatherCore

struct WeatherPhenomenonIconTests {
    @Test(arguments: [
        ("Clear", "sun.max"),
        ("Sunny", "sun.max"),
        ("Few clouds", "cloud.sun"),
        ("Variable clouds", "cloud.sun"),
        ("Cloudy with clear spells", "cloud.sun"),
        ("Partly cloudy", "cloud.sun"),
        ("Cloudy", "smoke"),
        ("Overcast", "smoke"),
        ("Light snow shower", "cloud.snow"),
        ("Moderate snow shower", "cloud.snow"),
        ("Heavy snow shower", "cloud.snow"),
        ("Light shower", "cloud.drizzle"),
        ("Moderate shower", "cloud.rain"),
        ("Heavy shower", "cloud.heavyrain"),
        ("Light rain", "cloud.drizzle"),
        ("Moderate rain", "cloud.rain"),
        ("Heavy rain", "cloud.heavyrain"),
        ("Risk of glaze", "thermometer.snowflake"),
        ("Light sleet", "cloud.sleet"),
        ("Moderate sleet", "cloud.sleet"),
        ("Light snow", "cloud.snow"),
        ("Moderate snow", "cloud.snow"),
        ("Heavy snow", "cloud.snow"),
        ("Light snowfall", "cloud.snow"),
        ("Moderate snowfall", "cloud.snow"),
        ("Heavy snowfall", "cloud.snow"),
        ("Snowstorm", "cloud.snow"),
        ("Drifting snow", "cloud.snow"),
        ("Hail", "cloud.hail"),
        ("Mist", "cloud.fog"),
        ("Fog", "cloud.fog"),
        ("Thunder", "cloud.bolt"),
        ("Thunderstorm", "cloud.bolt"),
    ])
    func knownPhenomenaMapToExpectedSFSymbols(phenomenon: String, expectedSymbol: String) {
        #expect(WeatherPhenomenonIcon.symbolName(for: phenomenon) == expectedSymbol)
    }

    @Test
    func mappingIsCaseInsensitiveAndTrimsWhitespace() {
        #expect(WeatherPhenomenonIcon.symbolName(for: "  few clouds \n") == "cloud.sun")
        #expect(WeatherPhenomenonIcon.symbolName(for: "HEAVY RAIN") == "cloud.heavyrain")
    }

    @Test(arguments: ["", "   \n", "Unknown phenomenon", "Volcanic ash"])
    func unknownOrBlankPhenomenaReturnDefaultSymbol(phenomenon: String) {
        #expect(WeatherPhenomenonIcon.symbolName(for: phenomenon) == WeatherPhenomenonIcon.defaultSymbolName)
        #expect(WeatherPhenomenonIcon.defaultSymbolName == "cloud")
    }

    @Test(arguments: [
        ("Clear", "Clear"),
        ("Sunny", "Sunny"),
        ("Few clouds", "Few clouds"),
        ("Variable clouds", "Variable clouds"),
        ("Cloudy with clear spells", "Cloudy with clear spells"),
        ("Partly cloudy", "Partly cloudy"),
        ("Cloudy", "Cloudy"),
        ("Overcast", "Overcast"),
        ("Light snow shower", "Light snow shower"),
        ("Moderate snow shower", "Moderate snow shower"),
        ("Heavy snow shower", "Heavy snow shower"),
        ("Light snow", "Light snow"),
        ("Moderate snow", "Moderate snow"),
        ("Heavy snow", "Heavy snow"),
        ("Light snowfall", "Light snowfall"),
        ("Moderate snowfall", "Moderate snowfall"),
        ("Heavy snowfall", "Heavy snowfall"),
        ("Snowstorm", "Snowstorm"),
        ("Drifting snow", "Drifting snow"),
        ("Light shower", "Light shower"),
        ("Moderate shower", "Moderate shower"),
        ("Heavy shower", "Heavy shower"),
        ("Light rain", "Light rain"),
        ("Moderate rain", "Moderate rain"),
        ("Heavy rain", "Heavy rain"),
        ("Light sleet", "Light sleet"),
        ("Moderate sleet", "Moderate sleet"),
        ("Risk of glaze", "Risk of glaze"),
        ("Hail", "Hail"),
        ("Mist", "Mist"),
        ("Fog", "Fog"),
        ("Thunder", "Thunder"),
        ("Thunderstorm", "Thunderstorm"),
    ])
    func knownPhenomenaMapToExpectedLocalizationKeys(phenomenon: String, expectedKey: String) {
        #expect(WeatherPhenomenonIcon.localizationKey(for: phenomenon) == expectedKey)
    }

    @Test
    func localizationKeyMappingIsCaseInsensitiveAndTrimsWhitespace() {
        #expect(WeatherPhenomenonIcon.localizationKey(for: "  few clouds \n") == "Few clouds")
        #expect(WeatherPhenomenonIcon.localizationKey(for: "HEAVY RAIN") == "Heavy rain")
    }

    @Test(arguments: ["", "   \n", "Unknown phenomenon", "Volcanic ash"])
    func unknownOrBlankPhenomenaReturnRawStringAsLocalizationKeyFallback(phenomenon: String) {
        #expect(WeatherPhenomenonIcon.localizationKey(for: phenomenon) == phenomenon)
    }
}
