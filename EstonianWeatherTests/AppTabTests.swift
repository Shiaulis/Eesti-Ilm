//
//  AppTabTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing

struct AppTabTests {
    @Test func tabsAreOrderedForecastsThenSettings() {
        #expect(AppTab.allCases == [.forecasts, .settings])
        #expect(AppTab.defaultTab == .forecasts)
        #expect(AppTab.forecasts.id == .forecasts)
        #expect(AppTab.settings.id == .settings)
    }

    @Test func tabsExposeExpectedSystemImages() {
        #expect(AppTab.forecasts.systemImageName == "cloud.sun")
        #expect(AppTab.settings.systemImageName == "gear")
    }
}
