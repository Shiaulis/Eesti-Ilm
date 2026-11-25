//
//  WeatherLanguage.swift
//  WeatherCore
//
//  Created by Andrius Shiaulis on 06.07.2025.
//

import Foundation

public enum WeatherLanguage: String, Equatable, Hashable, CaseIterable, Sendable {
    case english
    case estonian

    // MARK: - Current App Language -

    /// The forecast language resolved from the app's current preferred languages.
    ///
    /// Selects `.estonian` when Estonian is preferred over English, and defaults to `.english` otherwise.
    public static var current: WeatherLanguage {
        WeatherLanguage(preferredLanguages: Locale.preferredLanguages)
    }

    // MARK: - Init -

    /// Resolves the forecast language for a single locale.
    ///
    /// Selects `.estonian` for Estonian (`et`, including regional variants such as `et-EE` or `et_EE`),
    /// and defaults to `.english` for English and all unsupported languages.
    public init(locale: Locale) {
        self = Self.supportedLanguage(for: locale) ?? .english
    }

    /// Resolves the forecast language from an ordered list of preferred language identifiers
    /// (such as `Locale.preferredLanguages` or `Bundle.main.preferredLocalizations`).
    ///
    /// Picks the first supported language (`.estonian` or `.english`) in preference order,
    /// defaulting to `.english` if none match or the list is empty.
    public init(preferredLanguages: [String]) {
        for identifier in preferredLanguages {
            let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedIdentifier.isEmpty else { continue }

            if let match = Self.supportedLanguage(for: Locale(identifier: trimmedIdentifier)) {
                self = match
                return
            }
        }

        self = .english
    }

    // MARK: - Private API -

    private static func supportedLanguage(for locale: Locale) -> WeatherLanguage? {
        switch locale.language.languageCode {
        case .estonian: .estonian
        case .english: .english
        default: nil
        }
    }
}
