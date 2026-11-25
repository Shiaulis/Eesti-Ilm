//
//  UserRatingServiceTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing

@MainActor
final class UserRatingServiceTests {
    private let suiteName: String
    private let userDefaults: UserDefaults

    init() throws {
        self.suiteName = "com.shiaulis.EstonianWeatherTests.UserRatingService.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: self.suiteName))
        defaults.removePersistentDomain(forName: self.suiteName)
        self.userDefaults = defaults
    }

    deinit {
        UserDefaults(suiteName: self.suiteName)?.removePersistentDomain(forName: self.suiteName)
    }

    // MARK: - Helpers

    private func makeService(
        minimumLaunchCount: Int = UserRatingService.defaultMinimumLaunchCount,
        version: String? = "57"
    ) -> UserRatingService {
        UserRatingService(
            userDefaults: self.userDefaults,
            minimumLaunchCount: minimumLaunchCount,
            currentVersionProvider: { version }
        )
    }

    // MARK: - Tests

    @Test func recordLaunchIncrementsAndPersistsCount() {
        let service = self.makeService()

        #expect(service.launchCount == 0)
        #expect(service.recordLaunch() == 1)
        #expect(service.recordLaunch() == 2)
        #expect(service.recordLaunch() == 3)
        #expect(service.launchCount == 3)
        #expect(self.userDefaults.integer(forKey: UserRatingService.DefaultsKey.processCompletedCount) == 3)
    }

    @Test func doesNotRequestReviewBeforeLaunchThreshold() {
        let service = self.makeService()
        var reviewRequestCount = 0

        for _ in 1 ... 3 {
            service.recordLaunch()
            #expect(!service.shouldRequestReview)
            let prompted = service.requestReviewIfEligible {
                reviewRequestCount += 1
            }
            #expect(!prompted)
        }

        #expect(reviewRequestCount == 0)
        #expect(service.lastVersionPromptedForReview == nil)
    }

    @Test func requestsReviewOnFourthLaunchAndPersistsVersion() {
        let service = self.makeService(version: "57")
        var reviewRequestCount = 0

        for _ in 1 ... 4 {
            service.recordLaunch()
        }

        #expect(service.shouldRequestReview)
        let prompted = service.requestReviewIfEligible {
            reviewRequestCount += 1
        }

        #expect(prompted)
        #expect(reviewRequestCount == 1)
        #expect(service.lastVersionPromptedForReview == "57")
        #expect(
            self.userDefaults.string(forKey: UserRatingService.DefaultsKey.lastVersionPromptedForReview) == "57"
        )
    }

    @Test func requestsReviewAtMostOncePerVersion() {
        let service = self.makeService(version: "57")
        var reviewRequestCount = 0

        for _ in 1 ... 4 {
            service.recordLaunch()
        }

        #expect(service.requestReviewIfEligible { reviewRequestCount += 1 })

        for _ in 5 ... 7 {
            service.recordLaunch()
            #expect(!service.shouldRequestReview)
            #expect(!service.requestReviewIfEligible { reviewRequestCount += 1 })
        }

        #expect(reviewRequestCount == 1)
    }

    @Test func requestsReviewAgainWhenAppVersionChanges() {
        var reviewRequestCount = 0

        let oldVersionService = self.makeService(version: "57")
        for _ in 1 ... 4 {
            oldVersionService.recordLaunch()
        }

        #expect(oldVersionService.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 1)

        let newVersionService = self.makeService(version: "58")
        newVersionService.recordLaunch()
        #expect(newVersionService.shouldRequestReview)
        #expect(newVersionService.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 2)
        #expect(newVersionService.lastVersionPromptedForReview == "58")

        newVersionService.recordLaunch()
        #expect(!newVersionService.shouldRequestReview)
        #expect(!newVersionService.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 2)
    }

    @Test(arguments: [nil, "", "   "])
    func doesNotRequestReviewWhenVersionIsMissingOrBlank(version: String?) {
        let service = self.makeService(version: version)
        var reviewRequestCount = 0

        for _ in 1 ... 5 {
            service.recordLaunch()
        }

        #expect(!service.shouldRequestReview)
        #expect(!service.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 0)
        #expect(service.lastVersionPromptedForReview == nil)
    }

    @Test func handleAppLaunchCountsOncePerSessionAndPromptsAtThreshold() async {
        var reviewRequestCount = 0

        for expectedLaunch in 1 ... 3 {
            let sessionService = self.makeService(version: "57")
            let firstResult = await sessionService.handleAppLaunch(delay: .zero) {
                reviewRequestCount += 1
            }
            let secondResult = await sessionService.handleAppLaunch(delay: .zero) {
                reviewRequestCount += 1
            }

            #expect(!firstResult)
            #expect(!secondResult)
            #expect(sessionService.launchCount == expectedLaunch)
        }

        let fourthSessionService = self.makeService(version: "57")
        let prompted = await fourthSessionService.handleAppLaunch(delay: .zero) {
            reviewRequestCount += 1
        }
        let repeatedInSameSession = await fourthSessionService.handleAppLaunch(delay: .zero) {
            reviewRequestCount += 1
        }

        #expect(prompted)
        #expect(!repeatedInSameSession)
        #expect(fourthSessionService.launchCount == 4)
        #expect(reviewRequestCount == 1)

        let fifthSessionService = self.makeService(version: "57")
        let fifthPrompted = await fifthSessionService.handleAppLaunch(delay: .zero) {
            reviewRequestCount += 1
        }

        #expect(!fifthPrompted)
        #expect(fifthSessionService.launchCount == 5)
        #expect(reviewRequestCount == 1)
    }

    @Test func handleAppLaunchCancellationDoesNotMarkVersionAsPrompted() async {
        self.userDefaults.set(3, forKey: UserRatingService.DefaultsKey.processCompletedCount)
        let sessionService = self.makeService(version: "57")
        var reviewRequestCount = 0

        let task = Task { @MainActor in
            await sessionService.handleAppLaunch(delay: .seconds(10)) {
                reviewRequestCount += 1
            }
        }

        await Task.yield()
        task.cancel()
        let cancelledResult = await task.value

        #expect(!cancelledResult)
        #expect(sessionService.launchCount == 4)
        #expect(reviewRequestCount == 0)
        #expect(sessionService.lastVersionPromptedForReview == nil)

        let resumedResult = await sessionService.handleAppLaunch(delay: .zero) {
            reviewRequestCount += 1
        }

        #expect(resumedResult)
        #expect(sessionService.launchCount == 4)
        #expect(reviewRequestCount == 1)
        #expect(sessionService.lastVersionPromptedForReview == "57")
    }

    @Test func supportsCustomMinimumLaunchCount() {
        let service = self.makeService(minimumLaunchCount: 2, version: "57")
        var reviewRequestCount = 0

        service.recordLaunch()
        #expect(!service.requestReviewIfEligible { reviewRequestCount += 1 })

        service.recordLaunch()
        #expect(service.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 1)
    }

    @Test func nonPositiveMinimumLaunchCountClampsToOne() {
        let service = self.makeService(minimumLaunchCount: 0, version: "57")
        var reviewRequestCount = 0

        #expect(!service.shouldRequestReview)
        #expect(!service.requestReviewIfEligible { reviewRequestCount += 1 })

        service.recordLaunch()
        #expect(service.shouldRequestReview)
        #expect(service.requestReviewIfEligible { reviewRequestCount += 1 })
        #expect(reviewRequestCount == 1)
    }

    @Test func preserves210DefaultsKeysAcrossUpgrade() async {
        self.userDefaults.set(3, forKey: "processCompletedCount")
        self.userDefaults.set("56", forKey: "lastVersionPromptedForReview")

        let service = self.makeService(version: "57")
        var reviewRequestCount = 0

        let prompted = await service.handleAppLaunch(delay: .zero) {
            reviewRequestCount += 1
        }

        #expect(prompted)
        #expect(reviewRequestCount == 1)
        #expect(service.launchCount == 4)
        #expect(self.userDefaults.string(forKey: "lastVersionPromptedForReview") == "57")
    }
}
