//
//  File.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
import SWXMLHash

nonisolated protocol ForecastsParser {

    func decodeForecasts(from xmlData: Data) async throws -> [Forecast]

}

nonisolated struct SWXMLHashXMLParser: ForecastsParser {

    private let parser: XMLHash

    init() {
        self.parser = .config { configuration in
            configuration.detectParsingErrors = true
        }
    }

    func decodeForecasts(from xmlData: Data) async throws -> [Forecast] {
        let xml = self.parser.parse(xmlData)
        return try xml["forecasts"]["forecast"].value()
    }
}

struct Forecast: XMLObjectDeserialization, Decodable {
    let date: String
    let night: DayPart
    let day: DayPart

    static func deserialize(_ element: XMLIndexer) throws -> Forecast {
        try Self(
            date: element.value(ofAttribute: Self.CodingKeys.date.stringValue),
            night: element[Self.CodingKeys.night.stringValue].value(),
            day: element[Self.CodingKeys.night.stringValue].value()
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
        try Self.init(
            phenomenon: element["phenomenon"].value(),
            minimalTemperature: element[Self.CodingKeys.minimalTemperature.stringValue].value(),
            maximalTemperature: element[Self.CodingKeys.maximalTemperature.stringValue].value(),
            text: element[Self.CodingKeys.text.stringValue].value(),
            places: element[Self.CodingKeys.places.stringValue].value(),
            winds: element[Self.CodingKeys.winds.stringValue].value(),
            sea: element[Self.CodingKeys.sea.stringValue].value(),
            lake: element[Self.CodingKeys.lake.stringValue].value()
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
            name: element[Self.CodingKeys.name.stringValue].value(),
            phenomenon: element[Self.CodingKeys.phenomenon.stringValue].value(),
            minimalTemperature: element[Self.CodingKeys.minimalTemperature.stringValue].value(),
            maximalTemperature: element[Self.CodingKeys.maximalTemperature.stringValue].value()
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
            name: element[Self.CodingKeys.name.stringValue].value(),
            direction: element[Self.CodingKeys.direction.stringValue].value(),
            minimalSpeed: element[Self.CodingKeys.minimalSpeed.stringValue].value(),
            maximalSpeed: element[Self.CodingKeys.maximalSpeed.stringValue].value(),
            gust: element[Self.CodingKeys.gust.stringValue].value()
        )
    }
}
