//
//  TipJarStore.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import Foundation
import Observation
import OSLog
import StoreKit

nonisolated enum TipJarConfiguration {
    /// Reuse the consumable product ID from 2.1.0.
    /// App Store Connect availability will be verified after Apple Developer membership renewal (EES-20).
    static let productIDs = [
        "com.shiaulis.estonianweather.buyadrink",
    ]
}

nonisolated struct TipProduct: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let description: String
    let displayPrice: String
    let price: Decimal

    init(
        id: String,
        displayName: String,
        description: String,
        displayPrice: String,
        price: Decimal
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayPrice = displayPrice
        self.price = price
    }

    init(product: Product) {
        self.id = product.id
        self.displayName = product.displayName
        self.description = product.description
        self.displayPrice = product.displayPrice
        self.price = product.price
    }
}

nonisolated enum TipPurchaseOutcome: Equatable, Sendable {
    case purchased(productID: String)
    case pending
    case cancelled
}

nonisolated enum TipJarError: LocalizedError, Equatable, Sendable {
    case failedVerification
    case productNotFound
    case purchaseFailed(String)
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            String(localized: "Purchase could not be verified.")
        case .productNotFound:
            String(localized: "Product is currently unavailable.")
        case let .purchaseFailed(message):
            String(localized: "Purchase failed: \(message)")
        case let .loadFailed(message):
            String(localized: "Could not load tips: \(message)")
        }
    }
}

protocol TipJarClient: Sendable {
    nonisolated func fetchProducts(ids: [String]) async throws -> [TipProduct]
    nonisolated func purchase(productID: String) async throws -> TipPurchaseOutcome
    nonisolated func observeTransactionUpdates(
        onVerifiedTransaction: @escaping @Sendable (String) async -> Void
    ) -> Task<Void, Never>
}

final nonisolated class StoreKitTipJarClient: TipJarClient, Sendable {
    private let logger = Logger(subsystem: "com.shiaulis.EstonianWeather", category: "TipJar")

    func fetchProducts(ids: [String]) async throws -> [TipProduct] {
        do {
            let products = try await Product.products(for: ids)
            return products.map(TipProduct.init(product:))
        }
        catch {
            self.logger.error("Failed to fetch StoreKit products: \(error.localizedDescription)")
            throw TipJarError.loadFailed(error.localizedDescription)
        }
    }

    func purchase(productID: String) async throws -> TipPurchaseOutcome {
        let products: [Product]
        do {
            products = try await Product.products(for: [productID])
        }
        catch {
            self.logger.error("Failed to look up product \(productID): \(error.localizedDescription)")
            throw TipJarError.purchaseFailed(error.localizedDescription)
        }

        guard let product = products.first(where: { $0.id == productID }) else {
            throw TipJarError.productNotFound
        }

        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        }
        catch {
            self.logger.error("Purchase failed for \(productID): \(error.localizedDescription)")
            throw TipJarError.purchaseFailed(error.localizedDescription)
        }

        switch result {
        case let .success(verification):
            let transaction = try Self.checkVerified(verification)
            await transaction.finish()
            return .purchased(productID: transaction.productID)
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    func observeTransactionUpdates(
        onVerifiedTransaction: @escaping @Sendable (String) async -> Void
    ) -> Task<Void, Never> {
        Task { [logger] in
            // Handle transactions left unfinished from a previous launch, then keep listening.
            for await result in Transaction.unfinished {
                guard !Task.isCancelled else {
                    return
                }

                await Self.handle(result, logger: logger, onVerifiedTransaction: onVerifiedTransaction)
            }

            for await result in Transaction.updates {
                guard !Task.isCancelled else {
                    break
                }

                await Self.handle(result, logger: logger, onVerifiedTransaction: onVerifiedTransaction)
            }
        }
    }

    private static func handle(
        _ result: VerificationResult<Transaction>,
        logger: Logger,
        onVerifiedTransaction: @Sendable (String) async -> Void
    ) async {
        switch result {
        case let .verified(transaction):
            await transaction.finish()
            await onVerifiedTransaction(transaction.productID)
        case let .unverified(_, error):
            logger.error("Ignoring unverified transaction update: \(error.localizedDescription)")
        }
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw TipJarError.failedVerification
        case let .verified(safe):
            safe
        }
    }
}

@Observable
final class TipJarStore {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded([TipProduct])
        case failed(String)
    }

    enum PurchaseBanner: Equatable {
        case thankYou(productName: String)
        case pending
        case error(String)
    }

    private(set) var loadState = LoadState.idle
    private(set) var purchasingProductID: String?
    private(set) var banner: PurchaseBanner?

    private let client: any TipJarClient
    private let productIDs: [String]
    private var transactionUpdatesTask: Task<Void, Never>?

    init(
        client: any TipJarClient = StoreKitTipJarClient(),
        productIDs: [String] = TipJarConfiguration.productIDs
    ) {
        self.client = client
        self.productIDs = productIDs
    }

    isolated deinit {
        // An unstructured Task keeps running when its handle is dropped.
        self.transactionUpdatesTask?.cancel()
    }

    func startObservingTransactions() {
        guard self.transactionUpdatesTask == nil else {
            return
        }

        self.transactionUpdatesTask = self.client.observeTransactionUpdates { [weak self] productID in
            await self?.handleVerifiedTransaction(productID: productID)
        }
    }

    func stopObservingTransactions() {
        self.transactionUpdatesTask?.cancel()
        self.transactionUpdatesTask = nil
    }

    func loadProducts() async {
        self.loadState = .loading

        do {
            let products = try await self.client.fetchProducts(ids: self.productIDs)
            self.loadState = .loaded(Self.sortedProducts(products))
        }
        catch {
            self.loadState = .failed(error.localizedDescription)
        }
    }

    func purchase(_ product: TipProduct) async {
        guard self.purchasingProductID == nil else {
            return
        }

        self.purchasingProductID = product.id
        self.banner = nil
        defer {
            self.purchasingProductID = nil
        }

        do {
            let outcome = try await self.client.purchase(productID: product.id)
            switch outcome {
            case .purchased:
                self.banner = .thankYou(productName: product.displayName)
            case .pending:
                self.banner = .pending
            case .cancelled:
                break
            }
        }
        catch {
            self.banner = .error(error.localizedDescription)
        }
    }

    func dismissBanner() {
        self.banner = nil
    }

    // MARK: - Private

    private func handleVerifiedTransaction(productID: String) {
        let productName = self.productName(for: productID) ?? productID
        self.banner = .thankYou(productName: productName)
    }

    private func productName(for productID: String) -> String? {
        guard case let .loaded(products) = self.loadState else {
            return nil
        }

        return products.first(where: { $0.id == productID })?.displayName
    }

    static func sortedProducts(_ products: [TipProduct]) -> [TipProduct] {
        products.sorted { lhs, rhs in
            if lhs.price != rhs.price {
                return lhs.price < rhs.price
            }

            if lhs.displayName != rhs.displayName {
                return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
            }

            return lhs.id < rhs.id
        }
    }
}
