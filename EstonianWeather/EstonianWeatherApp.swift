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
    @State private var tipJarStore = TipJarStore()

    var body: some Scene {
        WindowGroup {
            RootNavigationView(tipJarStore: self.tipJarStore)
                .userRatingPrompt(using: self.ratingService)
                .task {
                    // Keep listening for the app's lifetime so transactions completed while
                    // Settings is closed (for example Ask to Buy approvals) are not missed.
                    self.tipJarStore.startObservingTransactions()
                }
        }
    }
}
