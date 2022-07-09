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

    init() {
        let userDefaults: UserDefaults = .standard
        let locale = WeatherLocale(locale: .current) ?? .english
        self.userDefaults = userDefaults
        self.weatherService = .init(
            weatherLocale: locale,
            responseParser: SWXMLResponseParser(logger: .init(category: .weatherModel)),
            networkClient: URLSessionNetworkClient()
        )
        self.userRatingService = .init(userDefaults: userDefaults)
        self.settingsService = .init(userDefaults: userDefaults)

        self.weatherModel = NetwokWeatherModel(
            weatherLocale: locale,
            responseParser: SWXMLResponseParser(logger: .init(category: .weatherModel)),
            networkClient: URLSessionNetworkClient()
        )

    }

    func start() async {
        await self.weatherService.start()
        await self.userRatingService.start()
        await self.settingsService.start()
    }

}
