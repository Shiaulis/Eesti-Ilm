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
        self.ratingService.makeAttemptToShowRating(in: windowScene)
    }

    func makePurchase(for product: StoreKit.Product) {
        Task {
            do {
                self.logger.log("Purchase requested")
                switch try await product.purchase() {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        self.logger.log("Purchase of \(product.displayName) successful")
                        await transaction.finish()
                    case .unverified(_, let verificationError):
                        self.logger.error("Failed to verify purchase: \(verificationError, privacy: .public)")
                    }
                case .pending:
                    self.logger.log("Purchase pending additional actions")
                case .userCancelled:
                    self.logger.log("Purchase cancelled by user")
                @unknown default:
                    break
                }
            }
            catch {
                self.logger.log("Failed to purchase: \(error, privacy: .public)")
            }
        }
    }

    // MARK: - Private -

    private func fetchProducts() {
        Task {
            self.products = try await Product.products(for: ["com.shiaulis.estonianweather.buyadrink"])
        }
    }
}
