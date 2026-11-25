//
//  WidgetDateFormatter.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import Foundation

enum WidgetDateFormatter {
    static func smallDateText(for date: Date, calendar: Calendar = .current, locale: Locale = .current) -> String {
        let monthDay = date.formatted(.dateTime.month(.wide).day().locale(locale))
        if let relative = relativeDayText(for: date, calendar: calendar, locale: locale) {
            return "\(relative), \(monthDay)"
        }
        return monthDay
    }

    static func mediumDateText(for date: Date, calendar: Calendar = .current, locale: Locale = .current) -> String {
        if let relative = relativeDayText(for: date, calendar: calendar, locale: locale) {
            return relative
        }
        return date.formatted(.dateTime.month(.abbreviated).day().locale(locale))
    }

    private static func relativeDayText(for date: Date, calendar: Calendar, locale: Locale) -> String? {
        guard calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) else {
            return nil
        }

        let formatStyle = Date.RelativeFormatStyle(
            allowedFields: [.day],
            presentation: .named,
            unitsStyle: .spellOut,
            locale: locale,
            calendar: calendar,
            capitalizationContext: .beginningOfSentence
        )
        return formatStyle.format(date)
    }
}
