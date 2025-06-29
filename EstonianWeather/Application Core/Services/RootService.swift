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

    // MARK: - Properties -

    let weatherService: WeatherService
    let userRatingService: UserRatingService
    let settingsService: SettingsService

    // MARK: - Init -

    init() {
        let locale = WeatherLocale(locale: .current) ?? .english
        self.weatherService = .init(
            weatherLocale: locale,
            responseParser: SWXMLResponseParser(),
            networkClient: URLSessionNetworkClient()
        )
        let keyValueStorage = KeyValueStorage(userDefaults: .standard)
        self.userRatingService = UserRatingService(keyValueStorage: keyValueStorage)
        self.settingsService = SettingsService(keyValueStorage: keyValueStorage)

    }

    func start() async {
        await self.weatherService.start()
        await self.userRatingService.start()
        await self.settingsService.start()
    }

}
