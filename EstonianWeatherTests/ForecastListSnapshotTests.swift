//
//  ForecastListSnapshotTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import WeatherCore

struct ForecastListSnapshotTests {
    @Test
    func buildsOneSectionPerDayWithNightThenDayItems() {
        let first = self.makeForecast()
        let second = self.makeForecast()

        let snapshot = ForecastListSnapshot.make(forecasts: [first, second], includesDisclaimer: false)

        #expect(snapshot.sectionIdentifiers == [.forecast(first.id), .forecast(second.id)])
        #expect(snapshot.itemIdentifiers(inSection: .forecast(first.id)) == [.night(first.id), .day(first.id)])
        #expect(snapshot.itemIdentifiers(inSection: .forecast(second.id)) == [.night(second.id), .day(second.id)])
    }

    @Test
    func appendsDisclaimerSectionLastWhenRequested() {
        let forecast = self.makeForecast()

        let snapshot = ForecastListSnapshot.make(forecasts: [forecast], includesDisclaimer: true)

        #expect(snapshot.sectionIdentifiers == [.forecast(forecast.id), .disclaimer])
        #expect(snapshot.itemIdentifiers(inSection: .disclaimer) == [.disclaimer])
    }

    @Test
    func isEmptyWithoutForecastsAndDisclaimer() {
        let snapshot = ForecastListSnapshot.make(forecasts: [], includesDisclaimer: false)

        #expect(snapshot.numberOfItems == 0)
        #expect(snapshot.numberOfSections == 0)
    }

    private func makeForecast() -> ForecastConfiguration {
        let dayPart = DayPartConfiguration(
            phenomenon: "Clear",
            temperatureRange: TemperatureRange(minimum: 1, maximum: 5),
            description: "Clear.",
            places: []
        )
        return ForecastConfiguration(date: .now, night: dayPart, day: dayPart)
    }
}
