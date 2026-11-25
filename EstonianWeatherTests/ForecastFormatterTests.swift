//
//  ForecastFormatterTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import WeatherCore

struct ForecastFormatterTests {
    @Test
    func sectionTitleIncludesRelativeDayForTodayAndTomorrow() throws {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = try #require(TimeZone(secondsFromGMT: 2 * 3600))
        calendar.timeZone = timeZone

        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 12))
        )
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: now))
        let dayAfterTomorrow = try #require(calendar.date(byAdding: .day, value: 2, to: now))

        let englishLocale = Locale(identifier: "en_US")
        let todayTitle = ForecastFormatter.sectionTitle(
            for: now,
            locale: englishLocale,
            calendar: calendar,
            now: now
        )
        let tomorrowTitle = ForecastFormatter.sectionTitle(
            for: tomorrow,
            locale: englishLocale,
            calendar: calendar,
            now: now
        )
        let laterTitle = ForecastFormatter.sectionTitle(
            for: dayAfterTomorrow,
            locale: englishLocale,
            calendar: calendar,
            now: now
        )

        #expect(todayTitle.contains("November"))
        #expect(todayTitle.contains("25"))
        #expect(todayTitle.contains("Wednesday"))
        #expect(todayTitle.hasSuffix("\nToday"))

        #expect(tomorrowTitle.contains("Thursday"))
        #expect(tomorrowTitle.hasSuffix("\nTomorrow"))

        #expect(laterTitle.contains("Friday"))
        #expect(!laterTitle.contains("\n"))
    }

    @Test
    func sectionTitleUsesTimeZoneOfSuppliedCalendar() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: -10 * 3600))

        // 23:30 on 25 November in UTC-10 is already 26 November in UTC and in most other zones.
        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 23, minute: 30))
        )

        let title = ForecastFormatter.sectionTitle(
            for: now,
            locale: Locale(identifier: "en_US"),
            calendar: calendar,
            now: now
        )

        #expect(title.contains("25"))
        #expect(title.contains("Wednesday"))
        #expect(title.hasSuffix("\nToday"))
    }

    @Test
    func sectionTitleSupportsEstonianLocale() throws {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = try #require(TimeZone(secondsFromGMT: 2 * 3600))
        calendar.timeZone = timeZone

        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 12))
        )

        let title = ForecastFormatter.sectionTitle(
            for: now,
            locale: Locale(identifier: "et_EE"),
            calendar: calendar,
            now: now
        )

        #expect(title.contains("november"))
        #expect(title.contains("Täna"))
    }

    @Test
    func temperatureRangeTextFormatsBounds() {
        #expect(ForecastFormatter.temperatureRangeText(for: TemperatureRange(minimum: -5, maximum: 2)) == "-5° - 2°")
        #expect(ForecastFormatter.temperatureRangeText(for: TemperatureRange(minimum: 12, maximum: 19)) == "12° - 19°")
    }

    @Test
    func placeTemperatureTextHandlesAllCases() {
        #expect(ForecastFormatter.placeTemperatureText(for: .minimum(-3)) == "-3°")
        #expect(ForecastFormatter.placeTemperatureText(for: .maximum(8)) == "8°")
        #expect(
            ForecastFormatter.placeTemperatureText(for: .range(TemperatureRange(minimum: 1, maximum: 6))) == "1° - 6°"
        )
        #expect(ForecastFormatter.placeTemperatureText(for: nil) == nil)
    }
}
