//
//  SettingsViewModel.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 22.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import UIKit
import StoreKit
import OSLog

@Observable
final class SettingsViewModel {

    // MARK: - Properties

    var products: [StoreKit.Product] = []

    var currentLanguageName: String { Locale.current.localizedLanguageName }

    let sourceDisclaimerText: String = L10n.Strings.sourceDisclaimer
    let urlDescription: String = "www.ilmateenindus.ee"
    let sourceDisclaimerURL: URL = .sourceDisclaimerURL

    private let ratingService: UserRatingService
    private let customerEntitlements = CustomerEntitlements()
    private let logger: Logger = .init(category: .settingsViewModel)

    // MARK: - Init

    init(ratingService: UserRatingService) {
        self.ratingService = ratingService
        fetchProducts()
    }

    // MARK: - Public methods

    func openApplicationSettings() {
        UIApplication.shared.open(URL.settings, options: [:])
    }

    func openSourceDisclaimerURL() {
        UIApplication.shared.open(.sourceDisclaimerURL, options: [:])
    }

    func makeAttemptToShowRating(in windowScene: UIWindowScene) {
        Task {
            do {
                try await self.ratingService.makeAttemptToShowRating(in: windowScene)
            }
            catch {
                self.logger.log("Failed to show rating: \(error, privacy: .public)")
            }
        }
    }

    func makePurchase(for product: StoreKit.Product) {
        Task {
            do {
                try await self.customerEntitlements.makePurchase(for: product)
            }
            catch {
                self.logger.log("Failed to purchase: \(error, privacy: .public)")
            }
        }
    }

    // MARK: - Private -

    private func fetchProducts() {
        Task {
            do {
                self.products = try await self.customerEntitlements.fetchProducts()
            }
            catch {
                self.logger.log("Failed to fetch products: \(error, privacy: .public)")
            }
        }
    }
}
