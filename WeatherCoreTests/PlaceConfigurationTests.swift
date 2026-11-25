//
//  PlaceConfigurationTests.swift
//  WeatherCoreTests
//

import Foundation
import Testing
@testable import WeatherCore

struct PlaceConfigurationTests {

    // MARK: - XML Fixture Conversion Tests

    @Test
    func weatherService_preservesAllPlaceTemperatureBoundCombinations() async throws {
        let client = StubPlaceWeatherNetworkClient(data: Data(Self.placeTemperatureBoundsXML.utf8))
        let service = WeatherService(networkClient: client, forecastsParser: SWXMLHashXMLParser())

        let configurations = try await service.getForecasts(for: .english)
        let forecast = try #require(configurations.first)

        // Night places: min-only and neither bound
        #expect(forecast.night.places.count == 2)

        let harku = forecast.night.places[0]
        #expect(harku.name == "Harku")
        #expect(harku.phenomenon == "Light snow")
        #expect(harku.temperature == .minimum(-5))
        #expect(harku.temperature?.minimum == -5)
        #expect(harku.temperature?.maximum == nil)
        #expect(harku.temperature?.range == nil)
        #expect(harku.temperature?.formattedTemperature == "-5°")

        let kuressaare = forecast.night.places[1]
        #expect(kuressaare.name == "Kuressaare")
        #expect(kuressaare.phenomenon == "Overcast")
        #expect(kuressaare.temperature == nil)

        // Day places: max-only and both bounds
        #expect(forecast.day.places.count == 2)

        let parnu = forecast.day.places[0]
        #expect(parnu.name == "Pärnu")
        #expect(parnu.phenomenon == "Clear")
        #expect(parnu.temperature == .maximum(8))
        #expect(parnu.temperature?.minimum == nil)
        #expect(parnu.temperature?.maximum == 8)
        #expect(parnu.temperature?.range == nil)
        #expect(parnu.temperature?.formattedTemperature == "8°")

        let tartu = forecast.day.places[1]
        #expect(tartu.name == "Tartu")
        #expect(tartu.phenomenon == "Partly cloudy")
        #expect(tartu.temperature == .range(TemperatureRange(minimum: 1, maximum: 6)))
        #expect(tartu.temperature?.minimum == 1)
        #expect(tartu.temperature?.maximum == 6)
        #expect(tartu.temperature?.range == TemperatureRange(minimum: 1, maximum: 6))
        #expect(tartu.temperature?.formattedTemperature == "1° - 6°")
    }

    // MARK: - PlaceTemperature API Tests

    @Test
    func placeTemperature_initWithBothBounds_createsRange() {
        let temperature = PlaceTemperature(minimum: -2, maximum: 4)

        #expect(temperature == .range(TemperatureRange(minimum: -2, maximum: 4)))
        #expect(temperature?.minimum == -2)
        #expect(temperature?.maximum == 4)
        #expect(temperature?.range == TemperatureRange(minimum: -2, maximum: 4))
        #expect(temperature?.formattedTemperature == "-2° - 4°")
    }

    @Test
    func placeTemperature_initWithMinimumOnly_preservesMinimum() {
        let temperature = PlaceTemperature(minimum: 0, maximum: nil)

        #expect(temperature == .minimum(0))
        #expect(temperature?.minimum == 0)
        #expect(temperature?.maximum == nil)
        #expect(temperature?.range == nil)
        #expect(temperature?.formattedTemperature == "0°")
    }

    @Test
    func placeTemperature_initWithMaximumOnly_preservesMaximum() {
        let temperature = PlaceTemperature(minimum: nil, maximum: 12)

        #expect(temperature == .maximum(12))
        #expect(temperature?.minimum == nil)
        #expect(temperature?.maximum == 12)
        #expect(temperature?.range == nil)
        #expect(temperature?.formattedTemperature == "12°")
    }

    @Test
    func placeTemperature_initWithNoBounds_returnsNil() {
        let temperature = PlaceTemperature(minimum: nil, maximum: nil)

        #expect(temperature == nil)
    }

    // MARK: - Fixtures

    private static let placeTemperatureBoundsXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <forecasts>
        <forecast date="2026-11-25">
            <night>
                <phenomenon>Light snow</phenomenon>
                <tempmin>-6</tempmin>
                <tempmax>0</tempmax>
                <text>Light snow overnight.</text>
                <place>
                    <name>Harku</name>
                    <phenomenon>Light snow</phenomenon>
                    <tempmin>-5</tempmin>
                </place>
                <place>
                    <name>Kuressaare</name>
                    <phenomenon>Overcast</phenomenon>
                </place>
            </night>
            <day>
                <phenomenon>Partly cloudy</phenomenon>
                <tempmin>1</tempmin>
                <tempmax>8</tempmax>
                <text>Partly cloudy with mild temperatures.</text>
                <place>
                    <name>Pärnu</name>
                    <phenomenon>Clear</phenomenon>
                    <tempmax>8</tempmax>
                </place>
                <place>
                    <name>Tartu</name>
                    <phenomenon>Partly cloudy</phenomenon>
                    <tempmin>1</tempmin>
                    <tempmax>6</tempmax>
                </place>
            </day>
        </forecast>
    </forecasts>
    """
}

private nonisolated struct StubPlaceWeatherNetworkClient: WeatherNetworkClient, Sendable {
    let data: Data

    func getForecastData(for _: WeatherLanguage) async throws -> Data {
        self.data
    }
}
