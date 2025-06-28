//
//  CustomerEntitlements.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 29.06.2025.
//

import Foundation
import StoreKit
import OSLog

final class CustomerEntitlements {

    // MARK: - Types -

    enum Error: Swift.Error {
        case unverifiedTransaction(id: String)
    }

    // MARK: - Properties -

    private static let productIDs: Set<String> = ["com.shiaulis.estonianweather.buyadrink"]

    private var transactionUpdateTask: Task<Void, any Swift.Error>?

    private let logger = Logger(category: .purchase)

    // MARK: - Init -

    init() {
        observeTransactionUpdates()
    }

    deinit {
        self.transactionUpdateTask?.cancel()
    }

    // MARK: - Public API -

    func fetchProducts() async throws -> [StoreKit.Product] {
        try await Product.products(for: Self.productIDs)
    }

    func process(_ transaction: Transaction) async {
        await transaction.finish()
        self.logger.log("Finished transaction \(transaction.id) for product with ID: \(transaction.productID)")
    }

    func makePurchase(for product: StoreKit.Product) async throws {
        do {
            switch try await product.purchase() {
            case .success(let verificationResult):
                let transaction = try await unwrapVerificationResult(verificationResult)
                await self.process(transaction)
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
            throw error
        }
    }

    // MARK: - Private API -

    private func observeTransactionUpdates() {
        self.transactionUpdateTask = Task { [weak self] in
            self?.logger.log("Started observing transaction updates")
            for await update in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? await unwrapVerificationResult(update) else { continue }
                await self.process(transaction)
            }
        }
    }

    private func unwrapVerificationResult(_ verificationResult: VerificationResult<Transaction>) async throws -> Transaction {
        switch verificationResult {
        case .verified(let transaction):
            self.logger.log("Transaction ID \(transaction.id) for \(transaction.productID) is verified")
            return transaction
        case .unverified(let transaction, let error):
            self.logger.error("Transaction ID \(transaction.id) for \(transaction.productID) is unverified: \(error)")
            throw Error.unverifiedTransaction(id: "\(transaction.id)")
        }
    }
}
