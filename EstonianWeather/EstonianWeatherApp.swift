//
//  EstonianWeatherApp.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import SwiftUI
import WeatherCore

@main
struct EstonianWeatherApp: App {
    let weatherService = WeatherService()
    var body: some Scene {
        WindowGroup {
            WeatherForecastView(forecasts: .sampleForecasts)
        }
    }
}
