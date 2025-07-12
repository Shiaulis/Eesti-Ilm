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

