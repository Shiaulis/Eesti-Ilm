//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation

public struct ForecastDisplayItem: Identifiable {
    public let id = UUID()
    public let naturalDateDescription: String
    public let shortDateDescription: String
    public var dayParts: [DayPartForecastDisplayItem] { [self.night, self.day].compactMap { $0 } }
    public let day: DayPartForecastDisplayItem?
    public let night: DayPartForecastDisplayItem?
}

public struct DayPartForecastDisplayItem: Identifiable {
    public enum DayPartType {
        case day, night
    }

    public let id = UUID()
    public let type: DayPartType
    public let weatherIconName: String?
    public let weatherDescription: String?
    public let temperatureRange: String?
    public let description: String?
    public let places: [PlaceDisplayItem]
}

public struct PlaceDisplayItem: Identifiable {
    public let id = UUID()
    public let name: String?
    public let weatherIconName: String?
    public let temperature: String?
}

extension ForecastDisplayItem {
    public static var test1: ForecastDisplayItem {
        .init(
            naturalDateDescription: "Today, 17 January",
            shortDateDescription: "Послезавтра",
            day: DayPartForecastDisplayItem.test2,
            night: DayPartForecastDisplayItem.test
        )
    }

    public static var test2: ForecastDisplayItem {
        .init(
            naturalDateDescription: "19 January",
            shortDateDescription: "19.01",
            day: DayPartForecastDisplayItem.test2,
            night: DayPartForecastDisplayItem.test
        )
    }

    public static var test3: ForecastDisplayItem {
        .init(
            naturalDateDescription: "19 January",
            shortDateDescription: "19.01",
            day: DayPartForecastDisplayItem.test3,
            night: DayPartForecastDisplayItem.test
        )
    }
}

extension DayPartForecastDisplayItem {

    public static var test: DayPartForecastDisplayItem {
        .init(
            type: .night,
            weatherIconName: "cloud.sun.bolt.fill",
            weatherDescription: "Moderate showwwwer",
            temperatureRange: "-20 | 30",
            description:
            """
            Partly cloudy. At first locally some rain. West wind 5-11,
            on coasts in gusts 15, at first on northern coast up to 18 m/s.
            Air temperature -2..+3∞C. Slippery roads!
            """,
            places: [
                PlaceDisplayItem.test1,
                PlaceDisplayItem.test2,
            ]
        )
    }

    public static var test2: DayPartForecastDisplayItem {
        .init(
            type: .day,
            weatherIconName: "cloud.sun.bolt.fill",
            weatherDescription: "Rain",
            temperatureRange: "–2…+3",
            description:
            """
            Partly cloudy. At first locally some rain. West wind 5-11,
            on coasts in gusts 15, at first on northern coast up to 18 m/s.
            Air temperature -2..+3∞C. Slippery roads!
            """,
            places: [
                PlaceDisplayItem.test1,
                PlaceDisplayItem.test2,
            ]
        )
    }

    public static var test3: DayPartForecastDisplayItem {
        .init(
            type: .day,
            weatherIconName: "cloud.sun.bolt.fill",
            weatherDescription: "Rain",
            temperatureRange: "–20|+30",
            description:
            """
            Partly cloudy. At first locally some rain. West wind 5-11,
            on coasts in gusts 15, at first on northern coast up to 18 m/s.
            Air temperature -2..+3∞C. Slippery roads!
            """,
            places: [
                PlaceDisplayItem.test1,
                PlaceDisplayItem.test2,
            ]
        )
    }

    public static var test4: DayPartForecastDisplayItem {
        .init(
            type: .day,
            weatherIconName: "cloud.sun.bolt.fill",
            weatherDescription: "Rain",
            temperatureRange: "–20|+30",
            description:
            """
            Partly cloudy. At first locally some rain. West wind 5-11,
            on coasts in gusts 15, at first on northern coast up to 18 m/s.
            Air temperature -2..+3∞C. Slippery roads!
            """,
            places: [
                PlaceDisplayItem.test1,
                PlaceDisplayItem.test2,
            ]
        )
    }
}

extension PlaceDisplayItem {

    public static var test1: PlaceDisplayItem {
        .init(
            name: "Harku",
            weatherIconName: "cloud.sun.bolt.fill",
            temperature: "+1"
        )
    }

    public static var test2: PlaceDisplayItem {
        .init(
            name: "Jõhvi",
            weatherIconName: "cloud.sun.bolt.fill",
            temperature: "+1"
        )
    }

}
