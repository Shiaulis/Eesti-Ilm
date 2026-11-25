//
//  ForecastServerModels.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 12.07.2025.
//

import Foundation
import SWXMLHash

struct Forecast: XMLObjectDeserialization, Decodable {
    let date: String
    let night: DayPart
    let day: DayPart

    static func deserialize(_ element: XMLIndexer) throws -> Forecast {
        try Self(
            date: element.value(ofAttribute: CodingKeys.date.stringValue),
            night: element[CodingKeys.night.stringValue].value(),
            day: element[CodingKeys.night.stringValue].value()
        )
    }
}

// MARK: - DayPart

struct DayPart: XMLObjectDeserialization, Decodable {
    let phenomenon: String
    let minimalTemperature: Int
    let maximalTemperature: Int
    let text: String
    let places: [Place]?
    let winds: [Wind]?
    let sea: String?
    let lake: String?

    enum CodingKeys: String, CodingKey {
        case phenomenon, text, sea
        case minimalTemperature = "tempmin"
        case maximalTemperature = "tempmax"
        case winds = "wind"
        case places = "place"
        case lake = "peipsi"
    }

    static func deserialize(_ element: XMLIndexer) throws -> DayPart {
        try Self(
            phenomenon: element["phenomenon"].value(),
            minimalTemperature: element[CodingKeys.minimalTemperature.stringValue].value(),
            maximalTemperature: element[CodingKeys.maximalTemperature.stringValue].value(),
            text: element[CodingKeys.text.stringValue].value(),
            places: element[CodingKeys.places.stringValue].value(),
            winds: element[CodingKeys.winds.stringValue].value(),
            sea: element[CodingKeys.sea.stringValue].value(),
            lake: element[CodingKeys.lake.stringValue].value()
        )
    }
}

// MARK: - Place

struct Place: XMLObjectDeserialization, Decodable {
    let name: String
    let phenomenon: String
    let minimalTemperature: Int?
    let maximalTemperature: Int?

    enum CodingKeys: String, CodingKey {
        case name, phenomenon
        case minimalTemperature = "tempmin"
        case maximalTemperature = "tempmax"
    }

    static func deserialize(_ element: XMLIndexer) throws -> Place {
        try Self(
            name: element[CodingKeys.name.stringValue].value(),
            phenomenon: element[CodingKeys.phenomenon.stringValue].value(),
            minimalTemperature: element[CodingKeys.minimalTemperature.stringValue].value(),
            maximalTemperature: element[CodingKeys.maximalTemperature.stringValue].value()
        )
    }
}

// MARK: - Wind

struct Wind: XMLObjectDeserialization, Decodable {
    let name: String
    let direction: String
    let minimalSpeed: Int
    let maximalSpeed: Int
    let gust: String? // Optional as it can be empty

    enum CodingKeys: String, CodingKey {
        case name, direction, gust
        case minimalSpeed = "speedmin"
        case maximalSpeed = "speedmax"
    }

    static func deserialize(_ element: XMLIndexer) throws -> Wind {
        try Self(
            name: element[CodingKeys.name.stringValue].value(),
            direction: element[CodingKeys.direction.stringValue].value(),
            minimalSpeed: element[CodingKeys.minimalSpeed.stringValue].value(),
            maximalSpeed: element[CodingKeys.maximalSpeed.stringValue].value(),
            gust: element[CodingKeys.gust.stringValue].value()
        )
    }
}
