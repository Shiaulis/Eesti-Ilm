//
//  ForecastDateFormatter.swift
//
//
//  Created by Andrius Shiaulis on 28.03.2021.
//

import Foundation

final class ForecastDateFormatter {
    enum Error: Swift.Error {
        case unableToMakeDateFromString
    }

    private let locale: Locale = .current

    private lazy var relativeDateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.locale = self.locale
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    func humanReadableDescription(for date: Date?) -> String? {
        guard let date = date else { return nil }

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
        guard let date = date else { return nil }

        return relativeDateDescription(for: date) ?? makeShortDateString(from: date)
    }

    func date(from string: String?) throws -> Date {
        guard let string = string else { throw Error.unableToMakeDateFromString }

        return try string.dateWithDefaultStrategy()
    }

    private func makeShortDateString(from date: Date) -> String {
        date.formatted(.dateTime.month(.wide).day(.twoDigits).locale(self.locale))
    }

    private func relativeDateDescription(for date: Date) -> String? {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return SWXMLResponseParser.todayLocalizedName
        }

        if calendar.isDateInTomorrow(date) {
            return SWXMLResponseParser.tomorrowLocalizedName
        }

        return nil
    }

    private func weekday(for date: Date) -> String? {
        date.formatted(Date.FormatStyle().weekday(.wide))
    }
}

private extension String {
    func dateWithDefaultStrategy() throws -> Date {
        let strategy = try Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
            timeZone: .timeZone(hoursFromGMT: 2)
        )
        return try Date(self, strategy: strategy)
    }
}

private extension TimeZone {
    enum Error: Swift.Error {
        case unableToCreateTimezone
    }

    static func timeZone(hoursFromGMT: Int) throws -> TimeZone {
        guard let timeZone = TimeZone(secondsFromGMT: 60 * 60 * hoursFromGMT) else {
            throw Error.unableToCreateTimezone
        }

        return timeZone
    }
}
