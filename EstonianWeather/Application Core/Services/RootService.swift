//
//  RootService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation
import WeatherLocale
import WeatherKit
import NetworkModule
import os

/// Main service for the whole application. Responsible for the rest application services management
final class RootService {

    let weatherModel: WeatherModel
    let weatherService: WeatherService
    let userRatingService: UserRatingService
    let settingsService: SettingsService

    private let userDefaults: UserDefaults

    private let logger: Logger

    init() {
        let userDefaults: UserDefaults = .standard
        self.userDefaults = userDefaults
        self.weatherService = .init()
        self.userRatingService = .init(userDefaults: userDefaults)
        self.settingsService = .init(userDefaults: userDefaults)
        self.logger = .init(category: .rootService)

        self.weatherModel = NetwokWeatherModel(
            weatherLocale: WeatherLocale(locale: .current) ?? .english,
            responseParser: SWXMLResponseParser(logger: .init(category: .weatherModel)),
            networkClient: URLSessionNetworkClient()
        )

    }

    func start() {
        self.userRatingService.start()
        self.settingsService.start()
        self.weatherService.start()
    }

}
