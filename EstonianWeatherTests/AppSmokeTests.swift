//
//  AppSmokeTests.swift
//  EstonianWeatherTests
//

import Foundation
import Testing

/// Runs inside the host app, so `Bundle.main` is the built `EstonianWeather.app`.
struct AppSmokeTests {
    @Test func hostAppIsConfiguredAndEmbedsWidget() throws {
        let app = Bundle.main

        #expect(app.bundleIdentifier == "com.shiaulis.EstonianWeather")
        #expect(app.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "Eesti Ilm")

        let plugIns = try #require(app.builtInPlugInsURL)
        let widget = try #require(Bundle(url: plugIns.appending(path: "EstonianWeatherWidgetExtension.appex")))
        #expect(widget.bundleIdentifier == "com.shiaulis.EstonianWeather.EstonianWeatherWidget")
    }
}
