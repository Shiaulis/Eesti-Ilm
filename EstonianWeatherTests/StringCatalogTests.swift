//
//  StringCatalogTests.swift
//  EstonianWeatherTests
//

import Foundation
import Testing

/// Checks `Resources/Localizable.xcstrings` from the source tree, so missing translator comments fail CI before
/// the catalog reaches translators.
///
/// New strings land in English only. Crowdin adds the Estonian translation through its pull request after merge,
/// and the app falls back to English until then, so a missing Estonian localization is allowed. An Estonian
/// localization that exists must not be empty: that guards against Crowdin or a merge writing empty values.
struct StringCatalogTests {
    @Test func catalogUsesEnglishAsSourceLanguage() throws {
        let catalog = try Self.loadCatalog()

        #expect(catalog.sourceLanguage == "en")
        #expect(!catalog.strings.isEmpty)
    }

    @Test func everyTranslatableStringHasTranslatorComment() throws {
        let catalog = try Self.loadCatalog()

        let keysWithoutComment = catalog.translatableKeys.filter { key in
            let comment = catalog.strings[key]?.comment ?? ""
            return comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        #expect(keysWithoutComment.isEmpty, "Strings without a translator comment: \(keysWithoutComment)")
    }

    @Test func estonianTranslationsAreNotEmpty() throws {
        let catalog = try Self.loadCatalog()

        // A missing Estonian localization is fine (see the type's documentation); an empty one is not.
        let keysWithEmptyEstonian = catalog.translatableKeys.filter { key in
            guard let estonian = catalog.strings[key]?.localizations?["et"] else { return false }

            let values = estonian.allValues
            return values.isEmpty || values.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }

        #expect(keysWithEmptyEstonian.isEmpty, "Strings with an empty Estonian translation: \(keysWithEmptyEstonian)")
    }

    // MARK: - Private

    private static func loadCatalog() throws -> StringCatalog {
        let catalogURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: catalogURL)
        return try JSONDecoder().decode(StringCatalog.self, from: data)
    }
}

private struct StringCatalog: Decodable {
    struct Entry: Decodable {
        let comment: String?
        let shouldTranslate: Bool?
        let localizations: [String: Localization]?
    }

    struct Localization: Decodable {
        struct StringUnit: Decodable {
            let value: String
        }

        let stringUnit: StringUnit?
        /// Plural or device variations, keyed by variation type and then by case (for example `plural` → `one`).
        let variations: [String: [String: Localization]]?

        /// The string's value, or the values of all its variations.
        var allValues: [String] {
            let nested = (self.variations ?? [:]).values.flatMap(\.values).flatMap(\.allValues)
            return (self.stringUnit.map { [$0.value] } ?? []) + nested
        }
    }

    let sourceLanguage: String
    let strings: [String: Entry]

    var translatableKeys: [String] {
        self.strings
            .filter { $0.value.shouldTranslate != false }
            .map(\.key)
            .sorted()
    }
}
