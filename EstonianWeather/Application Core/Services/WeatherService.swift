//
//  WeatherService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation
import NetworkModule
import WeatherKit
import WeatherLocale

final class WeatherService {
    private let weatherLocale: WeatherLocale
    private let responseParser: ResponseParser
    private let networkClient: NetworkClient

    init(weatherLocale: WeatherLocale, responseParser: ResponseParser, networkClient: NetworkClient) {
        self.weatherLocale = weatherLocale
        self.responseParser = responseParser
        self.networkClient = networkClient
    }

    func start() async {}

    func forecasts() async throws -> [ForecastDisplayItem] {
        let (data, response) = try await self.networkClient.data(from: .forecast(for: self.weatherLocale))

        try validate(response)
        return try self.responseParser.parse(forecastData: data).get()
    }

    func observations() async throws -> [ForecastDisplayItem] {
        let (data, response) = try await self.networkClient.data(from: .observations())

        try validate(response)
        return try self.responseParser.parse(forecastData: data).get()
    }

    // Should validate response code as well
    private func validate(_ response: URLResponse) throws {}
}
