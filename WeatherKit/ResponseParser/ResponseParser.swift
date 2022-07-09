//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation
import Combine

public protocol ResponseParser {
    func parse(forecastData: Data) -> Result<[ForecastDisplayItem], Swift.Error>
}

extension Publisher where Output == Data {

    func parseForecast(using parser: ResponseParser) -> AnyPublisher<[ForecastDisplayItem], Swift.Error> {
        self
            .tryMap { data in
                try parser.parse(forecastData: data).get()
            }
            .eraseToAnyPublisher()
    }

}
