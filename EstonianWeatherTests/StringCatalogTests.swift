//
//  StringCatalogTests.swift
//  EstonianWeatherTests
//

import Foundation
import Testing

/// Checks `Resources/Localizable.xcstrings` from the source tree, so missing translator comments or Estonian
/// translations fail CI before the catalog reaches translators.
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

    @Test func everyTranslatableStringHasEstonianTranslation() throws {
        let catalog = try Self.loadCatalog()

        // Any state counts (for example `needs_review`): this checks that a value exists, not that it was reviewed.
        let keysWithoutEstonian = catalog.translatableKeys.filter { key in
            let values = catalog.strings[key]?.localizations?["et"]?.allValues ?? []
            return values.isEmpty || values.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }

        #expect(keysWithoutEstonian.isEmpty, "Strings without an Estonian translation: \(keysWithoutEstonian)")
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
