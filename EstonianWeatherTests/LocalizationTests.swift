//
//  LocalizationTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing

struct LocalizationTests {
    @Test func appAndWidgetShipEnglishAndEstonianStrings() throws {
        let app = Bundle.main
        #expect(app.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en") != nil)
        #expect(app.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "et") != nil)

        let plugIns = try #require(app.builtInPlugInsURL)
        let widget = try #require(Bundle(url: plugIns.appending(path: "EstonianWeatherWidgetExtension.appex")))
        #expect(widget.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en") != nil)
        #expect(widget.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "et") != nil)

        let widgetEstonianBundleURL = try #require(widget.url(forResource: "et", withExtension: "lproj"))
        let widgetEstonianBundle = try #require(Bundle(url: widgetEstonianBundleURL))
        #expect(widgetEstonianBundle.localizedString(forKey: "Forecasts", value: nil, table: nil) == "Prognoosid")
    }

    @Test func appResolvesStringsForActiveTestPlanLocale() throws {
        let requestedLanguage = try #require(Locale.preferredLanguages.first)

        if requestedLanguage.hasPrefix("et") {
            #expect(Bundle.main.preferredLocalizations.first == "et")
            #expect(String(localized: "Forecasts") == "Prognoosid")
            #expect(String(localized: "Settings") == "Seaded")
            #expect(String(localized: .aboutMeDescription).hasPrefix("Tere"))
            #expect(String(localized: .sourceDisclaimer).contains("Keskkonnaagentuur"))
        }
        else {
            #expect(Bundle.main.preferredLocalizations.first == "en")
            #expect(String(localized: "Forecasts") == "Forecasts")
            #expect(String(localized: "Settings") == "Settings")
            #expect(String(localized: .aboutMeDescription).hasPrefix("Hey"))
            #expect(String(localized: .sourceDisclaimer).contains("Estonian Environment Agency"))
        }
    }

    @Test func settingsBundleIsIncludedInAppOnlyInEnglish() throws {
        let app = Bundle.main
        let settingsBundleURL = try #require(app.url(forResource: "Settings", withExtension: "bundle"))
        let settingsBundle = try #require(Bundle(url: settingsBundleURL))

        #expect(settingsBundle.url(forResource: "Root", withExtension: "plist") != nil)
        #expect(settingsBundle.url(forResource: "Root", withExtension: "strings", subdirectory: nil, localization: "en") != nil)
        #expect(settingsBundle.url(forResource: "Root", withExtension: "strings", subdirectory: nil, localization: "et") == nil)

        let plugIns = try #require(app.builtInPlugInsURL)
        let widget = try #require(Bundle(url: plugIns.appending(path: "EstonianWeatherWidgetExtension.appex")))
        #expect(widget.url(forResource: "Settings", withExtension: "bundle") == nil)
    }
}
