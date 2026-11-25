//
//  WeatherLanguageTests.swift
//  WeatherCoreTests
//

import Foundation
import Networking
import os
import Testing
@testable import WeatherCore

struct WeatherLanguageTests {

    // MARK: - Locale Resolution -

    @Test(arguments: ["et", "et-EE", "et_EE", "ET", "ET-EE", "et-Latn-EE"])
    func initWithLocale_estonianIdentifiers_selectsEstonian(identifier: String) {
        let language = WeatherLanguage(locale: Locale(identifier: identifier))
        #expect(language == .estonian)
    }

    @Test(arguments: ["en", "en-US", "en_US", "en-GB", "en-EE", "en_EE"])
    func initWithLocale_englishIdentifiers_selectsEnglish(identifier: String) {
        let language = WeatherLanguage(locale: Locale(identifier: identifier))
        #expect(language == .english)
    }

    @Test(arguments: ["ru", "ru-RU", "ru-EE", "de", "de-DE", "fi", "fi-FI", "lv", "lt", "", "und"])
    func initWithLocale_unsupportedIdentifiers_defaultsToEnglish(identifier: String) {
        let language = WeatherLanguage(locale: Locale(identifier: identifier))
        #expect(language == .english)
    }

    // MARK: - Preferred Languages Resolution -

    @Test(arguments: [
        ["et"],
        ["et-EE"],
        ["et_EE"],
        ["et-EE", "en-US"],
        ["ru-EE", "et-EE"],
        ["de-DE", "fi-FI", "et-EE", "en-US"],
        ["", "   ", "et-EE"],
    ])
    func initWithPreferredLanguages_estonianFirstSupported_selectsEstonian(languages: [String]) {
        let language = WeatherLanguage(preferredLanguages: languages)
        #expect(language == .estonian)
    }

    @Test(arguments: [
        ["en"],
        ["en-US"],
        ["en-EE"],
        ["en-US", "et-EE"],
        ["ru-EE", "en-US", "et-EE"],
        ["de-DE", "en-GB", "et-EE"],
    ])
    func initWithPreferredLanguages_englishFirstSupported_selectsEnglish(languages: [String]) {
        let language = WeatherLanguage(preferredLanguages: languages)
        #expect(language == .english)
    }

    @Test(arguments: [
        ["ru"],
        ["ru-EE", "de-DE", "fi-FI"],
        ["de", "fi"],
        ["", "   "],
    ])
    func initWithPreferredLanguages_onlyUnsupportedLanguages_defaultsToEnglish(languages: [String]) {
        let language = WeatherLanguage(preferredLanguages: languages)
        #expect(language == .english)
    }

    @Test
    func initWithPreferredLanguages_emptyList_defaultsToEnglish() {
        let language = WeatherLanguage(preferredLanguages: [])
        #expect(language == .english)
    }

    // MARK: - Current App Language -

    @Test
    func current_matchesPreferredLanguagesResolution() {
        #expect(WeatherLanguage.current == WeatherLanguage(preferredLanguages: Locale.preferredLanguages))
    }

    // MARK: - Conformance -

    @Test
    func allCases_containsOnlyEnglishAndEstonian() {
        #expect(WeatherLanguage.allCases == [.english, .estonian])
    }
}

@Suite(.serialized)
struct WeatherLanguageEndpointTests {

    @Test(arguments: [
        (WeatherLanguage.estonian, "est"),
        (WeatherLanguage.english, "eng"),
    ])
    func getForecastData_mapsLanguageToQueryParameter(
        language: WeatherLanguage,
        expectedQueryValue: String
    ) async throws {
        CapturingURLProtocol.reset()
        defer { CapturingURLProtocol.reset() }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CapturingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let client = URLSessionNetworkClient(urlSession: session)

        let data = try await client.getForecastData(for: language)
        #expect(data == CapturingURLProtocol.stubBody)

        let capturedRequest = try #require(CapturingURLProtocol.lastRequest)
        let url = try #require(capturedRequest.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.scheme == "https")
        #expect(components.host == "ilmateenistus.ee")
        #expect(components.path == "/ilma_andmed/xml/forecast.php")
        #expect(components.queryItems == [URLQueryItem(name: "lang", value: expectedQueryValue)])
    }
}

private final class CapturingURLProtocol: URLProtocol {
    static let stubBody = Data("<forecasts/>".utf8)

    private static let storage = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)

    static var lastRequest: URLRequest? {
        self.storage.withLock { $0 }
    }

    static func reset() {
        self.storage.withLock { $0 = nil }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let capturedRequest = self.request
        Self.storage.withLock { $0 = capturedRequest }

        guard let url = capturedRequest.url,
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: 200,
                  httpVersion: "HTTP/1.1",
                  headerFields: ["Content-Type": "application/xml"]
              )
        else {
            self.client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: Self.stubBody)
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
