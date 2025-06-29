//
//  SettingsService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation

final class SettingsService {

    // MARK: - Properties -

    private let keyValueStorage: KeyValueStorage

    // MARK: - Init -

    init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    // MARK: - Public API -

    func start() async {
        await storeVersionAndBuildNumber()
    }

    private func storeVersionAndBuildNumber() async {
        if let version = Bundle.main.string(for: .bundleShortVersionString) {
            await self.keyValueStorage.set(version, for: .version_preference)
        }

        if let build: String = Bundle.main.string(for: .bundleVersion) {
            await self.keyValueStorage.set(build, for: .build_preference)
        }
    }
}
