//
//  SettingsConfiguration.swift
//  EstonianWeather
//

import Foundation
import UIKit

nonisolated enum SettingsConfiguration {
    static let contactEmail = "shiaulis@gmail.com"
    static let sourceDisclaimerHost = "www.ilmateenistus.ee"

    @MainActor
    static var appSettingsURL: URL? {
        self.appSettingsURL(from: UIApplication.openSettingsURLString)
    }

    static func appSettingsURL(from urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        return URL(string: trimmed)
    }

    static func currentLanguageDisplayName(
        locale: Locale = .current,
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations
    ) -> String {
        guard let languageCode = self.resolvedLanguageCode(
            locale: locale,
            preferredLocalizations: preferredLocalizations
        )
        else {
            return ""
        }

        let displayLocale: Locale = if locale.language.languageCode?.identifier.lowercased() == languageCode {
            locale
        }
        else {
            Locale(identifier: languageCode)
        }

        return displayLocale.localizedString(forLanguageCode: languageCode) ?? languageCode
    }

    static func contactURL(
        email: String = SettingsConfiguration.contactEmail,
        subject: String? = nil
    ) -> URL? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty,
              trimmedEmail.contains("@"),
              trimmedEmail.rangeOfCharacter(from: .whitespacesAndNewlines) == nil
        else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = trimmedEmail

        if let subject {
            let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedSubject.isEmpty {
                components.queryItems = [URLQueryItem(name: "subject", value: trimmedSubject)]
            }
        }

        return components.url
    }

    static func sourceDisclaimerURL(
        locale: Locale = .current,
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations
    ) -> URL? {
        let languageCode = self.resolvedLanguageCode(
            locale: locale,
            preferredLocalizations: preferredLocalizations
        )
        let queryLanguage = languageCode == "et" ? "et" : "en"

        var components = URLComponents()
        components.scheme = "https"
        components.host = self.sourceDisclaimerHost
        components.path = "/"
        components.queryItems = [URLQueryItem(name: "lang", value: queryLanguage)]
        return components.url
    }

    // MARK: - Private

    private static func resolvedLanguageCode(
        locale: Locale,
        preferredLocalizations: [String]
    ) -> String? {
        if let firstLocalization = preferredLocalizations
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .first(where: { !$0.isEmpty })
        {
            if let languageCode = Locale(identifier: firstLocalization).language.languageCode?.identifier,
               !languageCode.isEmpty
            {
                return languageCode.lowercased()
            }

            return firstLocalization.lowercased()
        }

        guard let languageCode = locale.language.languageCode?.identifier,
              !languageCode.isEmpty
        else {
            return nil
        }

        return languageCode.lowercased()
    }
}
