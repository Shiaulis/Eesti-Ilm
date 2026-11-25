//
//  UserRatingService.swift
//  EstonianWeather
//

import Foundation
import OSLog

@MainActor
final class UserRatingService {
    enum DefaultsKey {
        static let processCompletedCount = "processCompletedCount"
        static let lastVersionPromptedForReview = "lastVersionPromptedForReview"
    }

    static let defaultMinimumLaunchCount = 4
    static let defaultPromptDelay = Duration.seconds(2)

    private let userDefaults: UserDefaults
    private let minimumLaunchCount: Int
    private let currentVersionProvider: () -> String?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.shiaulis.EstonianWeather",
        category: "rating"
    )

    private var hasRecordedLaunchForCurrentSession = false
    private var isAwaitingPromptDelay = false

    init(
        userDefaults: UserDefaults = .standard,
        minimumLaunchCount: Int = UserRatingService.defaultMinimumLaunchCount,
        currentVersionProvider: @escaping () -> String? = {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }
    ) {
        self.userDefaults = userDefaults
        self.minimumLaunchCount = max(1, minimumLaunchCount)
        self.currentVersionProvider = currentVersionProvider
    }

    // MARK: - State

    var launchCount: Int {
        self.userDefaults.integer(forKey: DefaultsKey.processCompletedCount)
    }

    var lastVersionPromptedForReview: String? {
        self.userDefaults.string(forKey: DefaultsKey.lastVersionPromptedForReview)
    }

    var shouldRequestReview: Bool {
        guard let currentVersion = self.currentVersion else {
            return false
        }

        return self.launchCount >= self.minimumLaunchCount
            && currentVersion != self.lastVersionPromptedForReview
    }

    private var currentVersion: String? {
        guard let version = self.currentVersionProvider(),
              !version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        return version
    }

    // MARK: - Actions

    @discardableResult
    func recordLaunch() -> Int {
        let count = self.launchCount + 1
        self.userDefaults.set(count, forKey: DefaultsKey.processCompletedCount)
        self.logger.debug("Application launched \(count) time(s)")
        return count
    }

    @discardableResult
    func requestReviewIfEligible(using requestReview: () -> Void) -> Bool {
        guard let currentVersion = self.currentVersion else {
            self.logger.fault("Expected to find a non-empty CFBundleVersion in the info dictionary")
            return false
        }
        guard self.launchCount >= self.minimumLaunchCount,
              currentVersion != self.lastVersionPromptedForReview
        else {
            return false
        }

        self.userDefaults.set(currentVersion, forKey: DefaultsKey.lastVersionPromptedForReview)
        requestReview()
        self.logger.info("Made review request for version \(currentVersion, privacy: .public)")
        return true
    }

    @discardableResult
    func handleAppLaunch(
        delay: Duration = UserRatingService.defaultPromptDelay,
        requestReview: () -> Void
    ) async -> Bool {
        if !self.hasRecordedLaunchForCurrentSession {
            self.hasRecordedLaunchForCurrentSession = true
            self.recordLaunch()
        }

        guard !self.isAwaitingPromptDelay else {
            return false
        }
        guard self.currentVersion != nil else {
            self.logger.fault("Expected to find a non-empty CFBundleVersion in the info dictionary")
            return false
        }
        guard self.shouldRequestReview else {
            return false
        }

        if delay > .zero {
            self.isAwaitingPromptDelay = true
            defer { self.isAwaitingPromptDelay = false }

            do {
                try await Task.sleep(for: delay)
            }
            catch {
                return false
            }
        }

        guard !Task.isCancelled else {
            return false
        }

        return self.requestReviewIfEligible(using: requestReview)
    }
}
