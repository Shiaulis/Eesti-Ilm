//
//  EstonianWeatherApp.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import SwiftUI

@main
struct EstonianWeatherApp: App {
    private let ratingService = UserRatingService()

    init() {
        SettingsConfiguration.publishVersionToSettingsBundle()
    }

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .userRatingPrompt(using: self.ratingService)
        }
    }
}
