//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation

public protocol WeatherModel {
    func forecasts() async throws -> [ForecastDisplayItem]
}
