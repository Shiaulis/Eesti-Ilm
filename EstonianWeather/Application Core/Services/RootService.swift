//
//  RootService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation
import NetworkModule
import os
import WeatherKit
import WeatherLocale

final class RootService {
    // MARK: - Properties -

    let weatherService: WeatherService
    let userRatingService: UserRatingService
    let settingsService: SettingsService

    // MARK: - Init -

    init() {
        let locale = Locale.current
        let weatherLocale = WeatherLocale(locale: locale) ?? .english
        self.weatherService = .init(
            weatherLocale: weatherLocale,
            responseParser: SWXMLResponseParser(locale: locale),
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
