//
//  WeatherPhenomenonIcon.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import Foundation

enum WeatherPhenomenonIcon {
    static func systemImageName(for phenomenon: String) -> String {
        switch phenomenon {
        case "Clear", "Sunny":
            "sun.max"
        case "Few clouds", "Variable clouds", "Cloudy with clear spells", "Partly cloudy":
            "cloud.sun"
        case "Cloudy", "Overcast":
            "smoke"
        case "Light snow shower", "Moderate snow shower", "Heavy snow shower",
             "Light snowfall", "Moderate snowfall", "Heavy snowfall",
             "Snowstorm", "Drifting snow":
            "cloud.snow"
        case "Light shower", "Light rain":
            "cloud.drizzle"
        case "Moderate shower", "Moderate rain":
            "cloud.rain"
        case "Heavy shower", "Heavy rain":
            "cloud.heavyrain"
        case "Risk of glaze":
            "thermometer.snowflake"
        case "Light sleet", "Moderate sleet":
            "cloud.sleet"
        case "Hail":
            "cloud.hail"
        case "Mist", "Fog":
            "cloud.fog"
        case "Thunder", "Thunderstorm":
            "wind"
        default:
            "cloud"
        }
    }
}

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
            presentation: .named,
            unitsStyle: .spellOut,
            locale: locale,
            calendar: calendar,
            capitalizationContext: .beginningOfSentence
        )
        return formatStyle.format(date)
    }
}
