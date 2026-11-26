//
//  ForecastFormatter.swift
//  EstonianWeather
//

import Foundation
import WeatherCore

nonisolated enum ForecastFormatter {
    static func sectionTitle(
        for date: Date,
        locale: Locale = .current,
        calendar: Calendar = .current,
        now: Date = .now
    ) -> String {
        let monthDay = date.formatted(
            Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
                .month(.wide)
                .day(.twoDigits)
        )
        let weekday = date.formatted(
            Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
                .weekday(.wide)
        )

        var title = "\(monthDay), \(weekday)"

        if let relative = self.relativeDescription(
            for: date,
            locale: locale,
            calendar: calendar,
            now: now
        ) {
            title += "\n\(relative)"
        }

        return title
    }

    static func temperatureRangeText(for temperatureRange: TemperatureRange) -> String {
        temperatureRange.formattedRange
    }

    static func placeTemperatureText(for temperature: PlaceTemperature?) -> String? {
        temperature?.formattedTemperature
    }

    // MARK: - Private

    private static func relativeDescription(
        for date: Date,
        locale: Locale,
        calendar: Calendar,
        now: Date
    ) -> String? {
        let dayOffset: Int
        if calendar.isDate(date, inSameDayAs: now) {
            dayOffset = 0
        }
        else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                calendar.isDate(date, inSameDayAs: tomorrow)
        {
            dayOffset = 1
        }
        else {
            return nil
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter.localizedString(from: DateComponents(day: dayOffset))
    }
}
