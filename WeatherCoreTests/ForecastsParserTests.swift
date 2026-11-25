//
//  ForecastsParserTests.swift
//  WeatherCoreTests
//

import Foundation
import Testing
@testable import WeatherCore

struct ForecastsParserTests {

    // MARK: - Parser Tests

    @Test
    func decodeForecasts_parsesNightAndDayDistinctly() async throws {
        let parser = SWXMLHashXMLParser()
        let xmlData = Data(Self.sampleForecastXML.utf8)

        let forecasts = try await parser.decodeForecasts(from: xmlData)

        #expect(forecasts.count == 2)

        let first = try #require(forecasts.first)
        #expect(first.date == "2026-11-25")

        // Verify night element
        #expect(first.night.phenomenon == "Light sleet")
        #expect(first.night.minimalTemperature == -4)
        #expect(first.night.maximalTemperature == 1)
        #expect(first.night.text == "Cloudy with sleet at night. Slippery roads.")
        #expect(first.night.sea == "Gulf of Finland: north wind 6-11 m/s.")
        #expect(first.night.lake == "Lake Peipsi: northerly wind 3-9 m/s.")

        let nightPlaces = try #require(first.night.places)
        #expect(nightPlaces.count == 2)
        #expect(nightPlaces[0].name == "Harku")
        #expect(nightPlaces[0].phenomenon == "Light sleet")
        #expect(nightPlaces[0].minimalTemperature == -2)
        #expect(nightPlaces[0].maximalTemperature == nil)
        #expect(nightPlaces[1].name == "Tartu")
        #expect(nightPlaces[1].phenomenon == "Risk of glaze")
        #expect(nightPlaces[1].minimalTemperature == -4)
        #expect(nightPlaces[1].maximalTemperature == nil)

        let nightWinds = try #require(first.night.winds)
        #expect(nightWinds.count == 1)
        #expect(nightWinds[0].name == "Kuusiku")
        #expect(nightWinds[0].direction == "North wind")
        #expect(nightWinds[0].minimalSpeed == 3)
        #expect(nightWinds[0].maximalSpeed == 7)
        #expect(nightWinds[0].gust == "12")

        // Verify day element has its own distinct values, not a copy of night
        #expect(first.day.phenomenon == "Sunny")
        #expect(first.day.minimalTemperature == 2)
        #expect(first.day.maximalTemperature == 7)
        #expect(first.day.text == "Clear sky and mild afternoon sun.")
        #expect(first.day.sea == "Baltic Sea: west wind 4-8 m/s.")
        #expect(first.day.lake == "Lake Peipsi: light southwest wind 2-5 m/s.")

        let dayPlaces = try #require(first.day.places)
        #expect(dayPlaces.count == 1)
        #expect(dayPlaces[0].name == "Pärnu")
        #expect(dayPlaces[0].phenomenon == "Clear")
        #expect(dayPlaces[0].minimalTemperature == nil)
        #expect(dayPlaces[0].maximalTemperature == 7)

        let dayWinds = try #require(first.day.winds)
        #expect(dayWinds.count == 2)
        #expect(dayWinds[0].name == "Väike-Maarja")
        #expect(dayWinds[0].direction == "West wind")
        #expect(dayWinds[0].minimalSpeed == 2)
        #expect(dayWinds[0].maximalSpeed == 5)
        #expect(dayWinds[0].gust == "")
        #expect(dayWinds[1].name == "Võrtsjärv")
        #expect(dayWinds[1].direction == "Southwest wind")
        #expect(dayWinds[1].minimalSpeed == 4)
        #expect(dayWinds[1].maximalSpeed == 9)
        #expect(dayWinds[1].gust == "14")

        // Verify second forecast without optional places/winds/sea/lake
        let second = forecasts[1]
        #expect(second.date == "2026-11-26")

        #expect(second.night.phenomenon == "Fog")
        #expect(second.night.minimalTemperature == -1)
        #expect(second.night.maximalTemperature == 2)
        #expect(second.night.text == "Dense fog inland overnight.")
        #expect(second.night.places == nil)
        #expect(second.night.winds == nil)
        #expect(second.night.sea == nil)
        #expect(second.night.lake == nil)

        #expect(second.day.phenomenon == "Partly cloudy")
        #expect(second.day.minimalTemperature == 3)
        #expect(second.day.maximalTemperature == 8)
        #expect(second.day.text == "Fog clears by noon, partly cloudy.")
        #expect(second.day.places == nil)
        #expect(second.day.winds == nil)
        #expect(second.day.sea == nil)
        #expect(second.day.lake == nil)
    }

    @Test
    func weatherService_convertsDistinctNightAndDayConfigurations() async throws {
        let client = StubWeatherNetworkClient(data: Data(Self.sampleForecastXML.utf8))
        let service = WeatherService(networkClient: client, forecastsParser: SWXMLHashXMLParser())

        let configurations = try await service.getForecasts(for: .english)

        #expect(configurations.count == 2)

        let first = try #require(configurations.first)
        #expect(first.night.phenomenon == "Light sleet")
        #expect(first.night.temperatureRange == TemperatureRange(minimum: -4, maximum: 1))
        #expect(first.night.description == "Cloudy with sleet at night. Slippery roads.")
        #expect(first.night.places.map(\.name) == ["Harku", "Tartu"])
        #expect(first.night.places.map(\.temperature) == [.minimum(-2), .minimum(-4)])
        #expect(first.night.winds.count == 1)
        #expect(first.night.winds[0].speedRange == SpeedRange(minimum: 3, maximum: 7))
        #expect(first.night.winds[0].gustDescription == "12")
        #expect(first.night.seaCondition == "Gulf of Finland: north wind 6-11 m/s.")
        #expect(first.night.lakeCondition == "Lake Peipsi: northerly wind 3-9 m/s.")

        #expect(first.day.phenomenon == "Sunny")
        #expect(first.day.temperatureRange == TemperatureRange(minimum: 2, maximum: 7))
        #expect(first.day.description == "Clear sky and mild afternoon sun.")
        #expect(first.day.places.map(\.name) == ["Pärnu"])
        #expect(first.day.places.map(\.temperature) == [.maximum(7)])
        #expect(first.day.winds.count == 2)
        #expect(first.day.winds[0].speedRange == SpeedRange(minimum: 2, maximum: 5))
        #expect(first.day.winds[0].gustDescription == nil)
        #expect(first.day.winds[1].speedRange == SpeedRange(minimum: 4, maximum: 9))
        #expect(first.day.winds[1].gustDescription == "14")
        #expect(first.day.seaCondition == "Baltic Sea: west wind 4-8 m/s.")
        #expect(first.day.lakeCondition == "Lake Peipsi: light southwest wind 2-5 m/s.")
    }

    // MARK: - Fixtures

    private static let sampleForecastXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <forecasts>
        <forecast date="2026-11-25">
            <night>
                <phenomenon>Light sleet</phenomenon>
                <tempmin>-4</tempmin>
                <tempmax>1</tempmax>
                <text>Cloudy with sleet at night. Slippery roads.</text>
                <place>
                    <name>Harku</name>
                    <phenomenon>Light sleet</phenomenon>
                    <tempmin>-2</tempmin>
                </place>
                <place>
                    <name>Tartu</name>
                    <phenomenon>Risk of glaze</phenomenon>
                    <tempmin>-4</tempmin>
                </place>
                <wind>
                    <name>Kuusiku</name>
                    <direction>North wind</direction>
                    <speedmin>3</speedmin>
                    <speedmax>7</speedmax>
                    <gust>12</gust>
                </wind>
                <sea>Gulf of Finland: north wind 6-11 m/s.</sea>
                <peipsi>Lake Peipsi: northerly wind 3-9 m/s.</peipsi>
            </night>
            <day>
                <phenomenon>Sunny</phenomenon>
                <tempmin>2</tempmin>
                <tempmax>7</tempmax>
                <text>Clear sky and mild afternoon sun.</text>
                <place>
                    <name>Pärnu</name>
                    <phenomenon>Clear</phenomenon>
                    <tempmax>7</tempmax>
                </place>
                <wind>
                    <name>Väike-Maarja</name>
                    <direction>West wind</direction>
                    <speedmin>2</speedmin>
                    <speedmax>5</speedmax>
                    <gust></gust>
                </wind>
                <wind>
                    <name>Võrtsjärv</name>
                    <direction>Southwest wind</direction>
                    <speedmin>4</speedmin>
                    <speedmax>9</speedmax>
                    <gust>14</gust>
                </wind>
                <sea>Baltic Sea: west wind 4-8 m/s.</sea>
                <peipsi>Lake Peipsi: light southwest wind 2-5 m/s.</peipsi>
            </day>
        </forecast>
        <forecast date="2026-11-26">
            <night>
                <phenomenon>Fog</phenomenon>
                <tempmin>-1</tempmin>
                <tempmax>2</tempmax>
                <text>Dense fog inland overnight.</text>
            </night>
            <day>
                <phenomenon>Partly cloudy</phenomenon>
                <tempmin>3</tempmin>
                <tempmax>8</tempmax>
                <text>Fog clears by noon, partly cloudy.</text>
            </day>
        </forecast>
    </forecasts>
    """
}

private nonisolated struct StubWeatherNetworkClient: WeatherNetworkClient, Sendable {
    let data: Data

    func getForecastData(for _: WeatherLanguage) async throws -> Data {
        self.data
    }
}
