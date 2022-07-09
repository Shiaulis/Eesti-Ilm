//
//  WeatherService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation
import WeatherKit
import NetworkModule
import WeatherLocale

final class WeatherService {

    @Published private(set) var forecasts: [ForecastDisplayItem]?
    @Published private(set) var userError: Swift.Error?

    private let weatherLocale: WeatherLocale
    private let responseParser: ResponseParser
    private let networkClient: NetworkClient

    init(weatherLocale: WeatherLocale, responseParser: ResponseParser, networkClient: NetworkClient) {
        self.weatherLocale = weatherLocale
        self.responseParser = responseParser
        self.networkClient = networkClient
    }

    func start() async {
        await fetch()
    }

    func fetch() async {
        do {
            let (data, response) = try await self.networkClient.data(from: .forecast(for: self.weatherLocale))

            try validate(response)
            self.forecasts = try self.responseParser.parse(forecastData: data).get()
        }
        catch {
            self.userError = error
        }
    }

    // Should validate response code as well
    private func validate(_ response: URLResponse) throws {}

}
