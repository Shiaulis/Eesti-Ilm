//
//  WeatherService.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation
import Networking
import OSLog

public final nonisolated class WeatherService  {

    // MARK: - Properties -

    private let networkClient: WeatherNetworkClient
    private let forecastsParser: ForecastsParser
    private let logger = Logger(subsystem: "com.shiaulis.WeatherCore", category: "WeatherService")

    // MARK: - Init -

    init(networkClient: WeatherNetworkClient, forecastsParser: ForecastsParser) {
        self.networkClient = networkClient
        self.forecastsParser = forecastsParser
    }
    
    public convenience init() {
        self.init(
            networkClient: URLSessionNetworkClient(urlSession: .shared),
            forecastsParser: SWXMLHashXMLParser(),
        )
    }

    // MARK: - Public API -

    public func getForecasts(for language: WeatherLanguage) async throws -> [ForecastConfiguration] {
        do {
            self.logger.log("Forecasts requested for \(language.rawValue) language")
            let data = try await self.networkClient.getForecastData(for: language)
            let forecasts = try await self.forecastsParser.decodeForecasts(from: data)
            self.logger.log("Receieved \(forecasts.count) forecasts")
            let configurations: [ForecastConfiguration] = try .from(forecasts: forecasts)
            self.logger.log("Parsed \(configurations.count) forecast configurations")
            return configurations
        }
        catch {
            self.logger.log("Failed to fetch or parse forecasts: \(error, privacy: .public)")
            throw error
        }
    }
}
