//
//  ForecastDateFormatter.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 08.07.2025.
//

import Foundation

struct ForecastDateFormatter: Sendable {

    // MARK: - Types -

    enum Error: Swift.Error {
        case unableToMakeDateFromString
        case unableToCreateTimezone
    }

    // MARK: - Properties -

    private let locale: Locale

    // MARK: - Init -

    init(locale: Locale = .current) {
        self.locale = locale
    }

    // MARK: - Internal API -

    func humanReadableDescription(for date: Date?) -> String? {
        guard let date else { return nil }

        var dateString = makeShortDateString(from: date)

        if let weekday = weekday(for: date) {
            dateString += ", \(weekday)"
        }

        if let description = relativeDateDescription(for: date) {
            dateString += "\n\(description)"
        }

        return dateString
    }

    func shortReadableDescription(for date: Date?) -> String? {
        guard let date else { return nil }

        return relativeDateDescription(for: date) ?? makeShortDateString(from: date)
    }

    func date(from string: String?) throws -> Date {
        guard let string else { throw Error.unableToMakeDateFromString }

        return try makeDateWithDefaultStrategy(from: string)
    }

    // MARK: - Private API -

    private func makeShortDateString(from date: Date) -> String {
        date.formatted(.dateTime.month(.wide).day(.twoDigits).locale(self.locale))
    }

    private func relativeDateDescription(for date: Date) -> String? {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let formatStyle = Date.RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .spellOut,
                locale: self.locale,
                calendar: calendar,
                capitalizationContext: .beginningOfSentence
            )

            return formatStyle.format(.now)
        }

        if calendar.isDateInTomorrow(date) {
            if let futureDay = Calendar.current.date(byAdding: .day, value: 1, to: .now) {
                let formatStyle = Date.RelativeFormatStyle(
                    presentation: .named,
                    unitsStyle: .spellOut,
                    locale: self.locale,
                    calendar: calendar,
                    capitalizationContext: .beginningOfSentence
                )

                return formatStyle.format(futureDay)
            }
        }

        return nil
    }

    private func weekday(for date: Date) -> String? {
        date.formatted(Date.FormatStyle().weekday(.wide))
    }

    private func makeDateWithDefaultStrategy(from string: String) throws -> Date {
        let strategy = try Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
            timeZone: makeTimeZone(hoursFromGMT: 2)
        )

        return try Date(string, strategy: strategy)
    }

    private func makeTimeZone(hoursFromGMT: Int) throws -> TimeZone {
        guard let timeZone = TimeZone(secondsFromGMT: 60 * 60 * hoursFromGMT) else {
            throw Error.unableToCreateTimezone
        }

        return timeZone
    }
}
