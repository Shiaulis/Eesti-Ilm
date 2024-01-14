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

        var dateString = date.formatted(.dateTime.month(.wide).day(.twoDigits).locale(self.locale))

        if let description = textOnlyDescription(for: date) {
            dateString += ", \(description)"
        }

        return dateString
    }

    func shortReadableDescription(for date: Date?) -> String? {
        guard let date = date else { return nil }

        return relativeDateDescription(for: date)
    }

    func date(from string: String?) throws -> Date {
        guard let string = string else { throw Error.unableToMakeDateFromString }
        return try string.dateWithDefaultStrategy()
    }

    private func textOnlyDescription(for date: Date) -> String? {
        guard let description = relativeDateDescription(for: date) else { return nil }
        guard let firstCharacter = description.first else { return nil }
        guard firstCharacter.isLetter else { return nil }

        return description.capitalized
    }

    private func relativeDateDescription(for date: Date) -> String? {
        self.relativeDateFormatter.string(from: date)
    }

}

private extension String {
    func dateWithDefaultStrategy() throws -> Date {
        let strategy = Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
            timeZone: try .timeZone(hoursFromGMT: 2)
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
