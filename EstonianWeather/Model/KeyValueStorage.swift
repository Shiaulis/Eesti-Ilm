//
//  KeyValueStorage.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 29.06.2025.
//

import Foundation
import OSLog

final actor KeyValueStorage {
    // MARK: - Types -

    enum Key: String {
        case processCompletedCount, lastVersionPromptedForReview
        // swiftlint:disable:next identifier_name
        case version_preference, build_preference
    }

    // MARK: - Properties -

    private let userDefaults: UserDefaults

    // MARK: - Init -

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public API -

    func getInteger(for key: Key) async -> Int {
        self.userDefaults.integer(forKey: key.rawValue)
    }

    func getString(for key: Key) async -> String? {
        self.userDefaults.string(forKey: key.rawValue)
    }

    func set(_ integer: Int, for key: Key) async {
        self.userDefaults.set(integer, forKey: key.rawValue)
    }

    func set(_ string: String, for key: Key) async {
        self.userDefaults.set(string, forKey: key.rawValue)
    }
}
