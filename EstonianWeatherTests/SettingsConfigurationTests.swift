//
//  SettingsConfigurationTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import UIKit

struct SettingsConfigurationTests {

    // MARK: - Current Language Display Name

    @Test func currentLanguageDisplayNameResolvesEnglish() {
        let name = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"]
        )

        #expect(name == "English")
    }

    @Test func currentLanguageDisplayNameResolvesEstonian() {
        let name = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "et_EE"),
            preferredLocalizations: ["et"]
        )

        #expect(name == "eesti")
    }

    @Test func currentLanguageDisplayNameUsesActiveAppLocalizationWhenDeviceLocaleDiffers() {
        let name = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "de_DE"),
            preferredLocalizations: ["en"]
        )

        #expect(name == "English")
    }

    @Test func currentLanguageDisplayNameHandlesRegionalLocalizationIdentifier() {
        let name = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["et-EE"]
        )

        #expect(name == "eesti")
    }

    @Test func currentLanguageDisplayNameFallsBackToLocaleWhenPreferredLocalizationsAreEmpty() {
        let englishName = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "en_GB"),
            preferredLocalizations: []
        )
        let estonianName = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "et_EE"),
            preferredLocalizations: []
        )

        #expect(englishName == "English")
        #expect(estonianName == "eesti")
    }

    @Test func currentLanguageDisplayNameFallsBackToRawCodeForUnknownLanguage() {
        let name = SettingsConfiguration.currentLanguageDisplayName(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["zz"]
        )

        #expect(name == "zz")
    }

    // MARK: - App Settings URL

    @Test
    @MainActor
    func defaultAppSettingsURLMatchesUIApplicationOpenSettingsURLString() throws {
        let url = try #require(SettingsConfiguration.appSettingsURL)

        #expect(url.absoluteString == UIApplication.openSettingsURLString)
    }

    @Test func appSettingsURLParsesValidStringAndRejectsBlankStrings() throws {
        let url = try #require(SettingsConfiguration.appSettingsURL(from: "app-settings:"))

        #expect(url.scheme == "app-settings")
        #expect(SettingsConfiguration.appSettingsURL(from: "") == nil)
        #expect(SettingsConfiguration.appSettingsURL(from: "   \n") == nil)
    }

    // MARK: - Contact URL

    @Test func defaultContactURLBuildsMailtoLink() throws {
        let url = try #require(SettingsConfiguration.contactURL())

        #expect(url.scheme == "mailto")
        #expect(url.absoluteString == "mailto:\(SettingsConfiguration.contactEmail)")
    }

    @Test func contactURLSupportsOptionalSubject() throws {
        let url = try #require(
            SettingsConfiguration.contactURL(
                email: "developer@example.com",
                subject: "Eesti Ilm feedback"
            )
        )
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.scheme == "mailto")
        #expect(components.path == "developer@example.com")
        #expect(components.queryItems == [URLQueryItem(name: "subject", value: "Eesti Ilm feedback")])
    }

    @Test(arguments: ["", "   ", "not-an-email", "user name@example.com"])
    func contactURLRejectsInvalidEmail(email: String) {
        #expect(SettingsConfiguration.contactURL(email: email) == nil)
    }

    // MARK: - Source Disclaimer URL

    @Test func sourceDisclaimerURLUsesEstonianWhenActiveLanguageIsEstonian() throws {
        let url = try #require(
            SettingsConfiguration.sourceDisclaimerURL(
                locale: Locale(identifier: "et_EE"),
                preferredLocalizations: ["et"]
            )
        )

        #expect(url.absoluteString == "https://www.ilmateenistus.ee/?lang=et")
    }

    @Test(arguments: ["en", "ru", "de", ""])
    func sourceDisclaimerURLDefaultsToEnglishForNonEstonianLanguages(localization: String) throws {
        let localizations = localization.isEmpty ? [] : [localization]
        let url = try #require(
            SettingsConfiguration.sourceDisclaimerURL(
                locale: Locale(identifier: "en_US"),
                preferredLocalizations: localizations
            )
        )

        #expect(url.absoluteString == "https://www.ilmateenistus.ee/?lang=en")
    }

    // MARK: - Localization

    @Test func settingsStringsResolveForActiveTestPlanLocale() throws {
        let requestedLanguage = try #require(Locale.preferredLanguages.first)

        if requestedLanguage.hasPrefix("et") {
            #expect(String(localized: "Settings") == "Seaded")
            #expect(String(localized: "Current language") == "Praegune keel")
            #expect(String(localized: "About me") == "Minust")
            #expect(String(localized: "Contact me") == "Võta ühendust")
            #expect(
                String(localized: "Opens app settings to change the language")
                    == "Avab rakenduse seaded keele muutmiseks"
            )
            #expect(SettingsConfiguration.currentLanguageDisplayName() == "eesti")
        }
        else {
            #expect(String(localized: "Settings") == "Settings")
            #expect(String(localized: "Current language") == "Current language")
            #expect(String(localized: "About me") == "About me")
            #expect(String(localized: "Contact me") == "Contact me")
            #expect(
                String(localized: "Opens app settings to change the language")
                    == "Opens app settings to change the language"
            )
            #expect(SettingsConfiguration.currentLanguageDisplayName() == "English")
        }
    }
}
