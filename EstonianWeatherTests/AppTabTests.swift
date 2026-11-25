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

    @Test func tabsLocalizeInEnglishAndEstonian() {
        #expect(self.localizedTitle(for: .forecasts, localeIdentifier: "en") == "Forecasts")
        #expect(self.localizedTitle(for: .settings, localeIdentifier: "en") == "Settings")
        #expect(self.localizedTitle(for: .forecasts, localeIdentifier: "et") == "Prognoosid")
        #expect(self.localizedTitle(for: .settings, localeIdentifier: "et") == "Seaded")
    }

    private func localizedTitle(for tab: AppTab, localeIdentifier: String) -> String {
        var resource = tab.titleResource
        resource.locale = Locale(identifier: localeIdentifier)
        return String(localized: resource)
    }
}
