//
//  ResponseParser.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation

public protocol ResponseParser {
    func parse(forecastData: Data) throws -> [ForecastDisplayItem]
}
