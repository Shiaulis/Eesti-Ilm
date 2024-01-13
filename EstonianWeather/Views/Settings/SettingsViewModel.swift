//
//  SettingsViewModel.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 22.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import UIKit
import PurchaseKit
import OSLog

final class SettingsViewModel {

    // MARK: - Properties

    @Published var products: [Product] = []

    var currentLanguageName: String { Locale.current.localizedLanguageName }

    let sourceDisclaimerText: String = L10n.Strings.sourceDisclaimer
    let urlDescription: String = "www.ilmateenindus.ee"
    let sourceDisclaimerURL: URL = .sourceDisclaimerURL

    private let ratingService: UserRatingService
    private let purchasemanager: InAppPurchaseManager

    // MARK: - Init

    init(ratingService: UserRatingService) {
        self.ratingService = ratingService
        self.purchasemanager = .init(
            inAppPurchaseIdentifiers: ["com.shiaulis.estonianweather.buyadrink"],
            logger: .init(category: .purchase)
        )

        self.purchasemanager.getProducts { completion in
            switch completion {
            case .failure(let error): assertionFailure("Failed to get products. Error: \(error.localizedDescription)")
            case .success(let products): self.products = products
            }
        }
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

    func makePurchase(for product: Product) {
        self.purchasemanager.purchase(product: product) { error in
            if let error = error {
                assertionFailure("Error while making purchase. Error: \(error)")
                return
            }
        }
    }
}
