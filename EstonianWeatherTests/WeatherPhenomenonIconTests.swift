//
//  WeatherPhenomenonIconTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Testing

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
        ("Light snowfall", "cloud.snow"),
        ("Moderate snowfall", "cloud.snow"),
        ("Heavy snowfall", "cloud.snow"),
        ("Snowstorm", "cloud.snow"),
        ("Drifting snow", "cloud.snow"),
        ("Hail", "cloud.hail"),
        ("Mist", "cloud.fog"),
        ("Fog", "cloud.fog"),
        ("Thunder", "wind"),
        ("Thunderstorm", "wind"),
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
    func unknownOrBlankPhenomenaReturnNil(phenomenon: String) {
        #expect(WeatherPhenomenonIcon.symbolName(for: phenomenon) == nil)
    }
}
