//
//  UserRatingService.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 30.12.2020.
//

import Foundation
import StoreKit
import OSLog

final class UserRatingService {

    // MARK: - Types -

    enum Error: Swift.Error {
        case unableToGetCurrentVersion
    }

    // MARK: - Properties -

    private let logger = Logger(category: .rating)
    private let keyValueStorage: KeyValueStorage

    // MARK: - Init -

    init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    // MARK: - Public API -

    func start() async {
        await incrementLauchCounter()
    }

    @MainActor
    func makeAttemptToShowRating(in windowScene: UIWindowScene) async throws {
        let currentVersion = try getCurrentAppVersion()
        guard await isValidShowRatingAttempt(for: currentVersion) else {
            return
        }

        try await Task.sleep(for: .seconds(2))

        AppStore.requestReview(in: windowScene)
        await self.keyValueStorage.set(currentVersion, for: .lastVersionPromptedForReview)
        self.logger.log("Made request to show user rating")
    }

    // MARK: - Private API -

    private func incrementLauchCounter() async {
        // If the count has not yet been stored, this will return 0
        var count = await self.keyValueStorage.getInteger(for: .processCompletedCount)
        count += 1
        await self.keyValueStorage.set(count, for: .processCompletedCount)
        self.logger.debug("Application launched \(count) time(s)")
    }

    private func isValidShowRatingAttempt(for currentVersion: String) async -> Bool {
        let lastVersionPromptedForReview = await self.keyValueStorage.getString(for: .lastVersionPromptedForReview)
        let count = await self.keyValueStorage.getInteger(for: .processCompletedCount)

        return count >= 4 && currentVersion != lastVersionPromptedForReview
    }

    private func getCurrentAppVersion() throws -> String {
        guard let currentVersion = Bundle.main.string(for: .bundleVersion) else {
            throw Error.unableToGetCurrentVersion
        }

        return currentVersion
    }

}
