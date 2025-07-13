//
//  EstonianWeatherApp.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import SwiftUI

@main
struct EstonianWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Forecasts", systemImage: "sun.haze.fill") {
                    ForecastListView()
                }
                Tab("About", systemImage: "info.circle") {
                    AboutView()
                }
            }
            .tabViewStyle(.sidebarAdaptable)
        }
    }
}
