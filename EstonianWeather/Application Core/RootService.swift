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
    let ratingService: AppStoreRatingService

    private let userDefaults: UserDefaults

    private let logger: Logger

    init() {
        let userDefaults: UserDefaults = .standard
        self.userDefaults = userDefaults
        self.ratingService = .init(userDefaults: userDefaults)
        self.logger = .init(category: .rootService)

        self.weatherModel = NetwokWeatherModel(
            weatherLocale: WeatherLocale(locale: .current) ?? .english,
            responseParser: SWXMLResponseParser(logger: .init(category: .weatherModel)),
            networkClient: URLSessionNetworkClient()
        )

        storeVersionAndBuildNumberToUserDefaults()
        ratingService.incrementLauchCounter()
    }

    private func storeVersionAndBuildNumberToUserDefaults() {
        if let version = Bundle.main.string(for: .bundleShortVersionString) {
            self.userDefaults.set(version, for: .version_preference)
        }

        if let build: String = Bundle.main.string(for: .bundleVersion) {
            self.userDefaults.set(build, for: .build_preference)
        }
    }
}

private extension WeatherLocale {

    enum Error: Swift.Error {
        case undefinedLocale
    }

    init?(locale: Locale) {
        switch locale.languageCode {
        case "en": self = .english
        case "ru": self = .russian
        case "et": self = .estonian
        default: return nil
        }
    }
}
