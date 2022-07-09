//
//  SettingsService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation

final class SettingsService {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func start() {
        storeVersionAndBuildNumberToUserDefaults()
    }

    private func storeVersionAndBuildNumberToUserDefaults() {
        if let version = Bundle.main.string(for: .bundleShortVersionString) {
            self.userDefaults.set(version, for: .version_preference)
        }

        if let build: String = Bundle.main.string(for: .bundleVersion) {
            self.userDefaults.set(build, for: .build_preference)
        }
    }
}
