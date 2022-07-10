//
//  File.swift
//
//
//  Created by Andrius Shiaulis on 06.03.2021.
//

import Foundation
import Combine
import NetworkModule
import WeatherLocale

public final class NetwokWeatherModel: WeatherModel {

    // MARK: - Properties

    private let responseParser: ResponseParser
    private let networkClient: NetworkClient
    private let weatherLocale: WeatherLocale

    // MARK: - Init

    public init(weatherLocale: WeatherLocale, responseParser: ResponseParser, networkClient: NetworkClient) {
        self.weatherLocale = weatherLocale
        self.responseParser = responseParser
        self.networkClient = networkClient
    }

    // MARK: - Public

    public func forecasts() async throws -> [ForecastDisplayItem] {
        let (data, response) = try await self.networkClient.data(from: .forecast(for: self.weatherLocale))

        try validate(response)
        return try self.responseParser.parse(forecastData: data).get()
    }

    public func observations() async throws -> [ForecastDisplayItem] {
        let (data, response) = try await self.networkClient.data(from: .observations())

        try validate(response)
        return try self.responseParser.parse(forecastData: data).get()
    }

    // Should validate response code as well
    private func validate(_ response: URLResponse) throws {}

}
