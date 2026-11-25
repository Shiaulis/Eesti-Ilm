//
//  TipJarStoreTests.swift
//  EstonianWeatherTests
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

@testable import EstonianWeather
import Foundation
import Testing

@MainActor
struct TipJarStoreTests {

    // MARK: - Configuration & Sorting

    @Test func configurationReusesLegacyConsumableProductID() {
        #expect(TipJarConfiguration.productIDs == ["com.shiaulis.estonianweather.buyadrink"])
    }

    @Test func sortedProductsOrdersByPriceThenDisplayNameThenID() {
        let products = [
            TipProduct(id: "z", displayName: "Coffee", description: "", displayPrice: "€3.00", price: 3),
            TipProduct(id: "b", displayName: "Meal", description: "", displayPrice: "€10.00", price: 10),
            TipProduct(id: "a", displayName: "Coffee", description: "", displayPrice: "€3.00", price: 3),
            TipProduct(id: "c", displayName: "Apple", description: "", displayPrice: "€3.00", price: 3),
        ]

        let sorted = TipJarStore.sortedProducts(products)

        #expect(sorted.map(\.id) == ["c", "a", "z", "b"])
    }

    // MARK: - Product Loading

    @Test func loadProductsPopulatesSortedProducts() async {
        let expensive = TipProduct(
            id: "com.shiaulis.estonianweather.meal",
            displayName: "Buy a meal",
            description: "Large tip",
            displayPrice: "€9.99",
            price: Decimal(string: "9.99") ?? 9.99
        )
        let drink = TipProduct(
            id: "com.shiaulis.estonianweather.buyadrink",
            displayName: "Buy me a drink",
            description: "Support application development",
            displayPrice: "€5.49",
            price: Decimal(string: "5.49") ?? 5.49
        )
        let client = MockTipJarClient(fetchResult: .success([expensive, drink]))
        let store = TipJarStore(client: client, productIDs: [expensive.id, drink.id])

        await store.loadProducts()

        #expect(store.loadState == .loaded([drink, expensive]))
    }

    @Test func loadProductsHandlesEmptyResponse() async {
        let client = MockTipJarClient(fetchResult: .success([]))
        let store = TipJarStore(client: client)

        await store.loadProducts()

        #expect(store.loadState == .loaded([]))
    }

    @Test func loadProductsSetsFailedStateOnError() async {
        let client = MockTipJarClient(fetchResult: .failure(TipJarError.loadFailed("Network offline")))
        let store = TipJarStore(client: client)

        await store.loadProducts()

        #expect(store.loadState == .failed(TipJarError.loadFailed("Network offline").localizedDescription))
    }

    // MARK: - Purchases

    @Test func purchaseSuccessSetsThankYouBannerAndClearsPurchasingState() async {
        let product = Self.sampleProduct
        let client = MockTipJarClient(
            fetchResult: .success([product]),
            purchaseResult: .success(.purchased(productID: product.id))
        )
        let store = TipJarStore(client: client)
        await store.loadProducts()

        await store.purchase(product)

        #expect(store.purchasingProductID == nil)
        #expect(store.banner == .thankYou(productName: product.displayName))

        store.dismissBanner()
        #expect(store.banner == nil)
    }

    @Test func purchaseCancelledLeavesBannerCleared() async {
        let product = Self.sampleProduct
        let client = MockTipJarClient(
            fetchResult: .success([product]),
            purchaseResult: .success(.cancelled)
        )
        let store = TipJarStore(client: client)
        await store.loadProducts()

        await store.purchase(product)

        #expect(store.purchasingProductID == nil)
        #expect(store.banner == nil)
    }

    @Test func purchasePendingSetsPendingBanner() async {
        let product = Self.sampleProduct
        let client = MockTipJarClient(
            fetchResult: .success([product]),
            purchaseResult: .success(.pending)
        )
        let store = TipJarStore(client: client)
        await store.loadProducts()

        await store.purchase(product)

        #expect(store.purchasingProductID == nil)
        #expect(store.banner == .pending)
    }

    @Test func purchaseFailureSetsErrorBanner() async {
        let product = Self.sampleProduct
        let client = MockTipJarClient(
            fetchResult: .success([product]),
            purchaseResult: .failure(TipJarError.failedVerification)
        )
        let store = TipJarStore(client: client)
        await store.loadProducts()

        await store.purchase(product)

        #expect(store.purchasingProductID == nil)
        #expect(store.banner == .error(TipJarError.failedVerification.localizedDescription))
    }

    @Test func transactionUpdatesTriggerThankYouBanner() async throws {
        let product = Self.sampleProduct
        let client = MockTipJarClient(fetchResult: .success([product]))
        let store = TipJarStore(client: client)
        await store.loadProducts()
        store.startObservingTransactions()
        defer { store.stopObservingTransactions() }

        await client.waitUntilObserving()
        await client.emitVerifiedTransaction(productID: product.id)
        try await Task.sleep(for: .milliseconds(50))

        #expect(store.banner == .thankYou(productName: product.displayName))
    }

    @Test func deallocatingStoreCancelsTransactionObservation() {
        let client = LongRunningObservationClient()
        var store: TipJarStore? = TipJarStore(client: client)
        store?.startObservingTransactions()
        #expect(!client.observationTask.isCancelled)

        store = nil

        #expect(client.observationTask.isCancelled)
    }

    // MARK: - Localization

    @Test func tipJarStringsResolveForActiveTestPlanLocale() throws {
        let requestedLanguage = try #require(Locale.preferredLanguages.first)

        if requestedLanguage.hasPrefix("et") {
            #expect(String(localized: "Tip jar") == "Toeta arendajat")
            #expect(String(localized: "Thank you for your support!") == "Aitäh toetuse eest!")
        }
        else {
            #expect(String(localized: "Tip jar") == "Tip jar")
            #expect(String(localized: "Thank you for your support!") == "Thank you for your support!")
        }
    }

    // MARK: - Helpers

    private static let sampleProduct = TipProduct(
        id: "com.shiaulis.estonianweather.buyadrink",
        displayName: "Buy me a drink",
        description: "Support application development",
        displayPrice: "€5.49",
        price: Decimal(string: "5.49") ?? 5.49
    )
}

private actor MockTipJarClientState {
    var onVerifiedTransaction: (@Sendable (String) async -> Void)?
    private var readyContinuations = [CheckedContinuation<Void, Never>]()

    func setHandler(_ handler: @escaping @Sendable (String) async -> Void) {
        self.onVerifiedTransaction = handler
        let continuations = self.readyContinuations
        self.readyContinuations.removeAll()
        for continuation in continuations {
            continuation.resume()
        }
    }

    func waitUntilReady() async {
        if self.onVerifiedTransaction != nil {
            return
        }

        await withCheckedContinuation { continuation in
            self.readyContinuations.append(continuation)
        }
    }

    func emit(_ productID: String) async {
        await self.onVerifiedTransaction?(productID)
    }
}

private final class MockTipJarClient: TipJarClient, Sendable {
    private let fetchResult: Result<[TipProduct], any Error>
    private let purchaseResult: Result<TipPurchaseOutcome, any Error>
    private let state = MockTipJarClientState()

    init(
        fetchResult: Result<[TipProduct], any Error> = .success([]),
        purchaseResult: Result<TipPurchaseOutcome, any Error> = .success(.cancelled)
    ) {
        self.fetchResult = fetchResult
        self.purchaseResult = purchaseResult
    }

    func fetchProducts(ids _: [String]) async throws -> [TipProduct] {
        try self.fetchResult.get()
    }

    func purchase(productID _: String) async throws -> TipPurchaseOutcome {
        try self.purchaseResult.get()
    }

    func observeTransactionUpdates(
        onVerifiedTransaction: @escaping @Sendable (String) async -> Void
    ) -> Task<Void, Never> {
        let state = self.state
        return Task {
            await state.setHandler(onVerifiedTransaction)
        }
    }

    func waitUntilObserving() async {
        await self.state.waitUntilReady()
    }

    func emitVerifiedTransaction(productID: String) async {
        await self.state.emit(productID)
    }
}

private final class LongRunningObservationClient: TipJarClient, Sendable {
    let observationTask = Task<Void, Never> {
        try? await Task.sleep(for: .seconds(60))
    }

    func fetchProducts(ids _: [String]) async throws -> [TipProduct] {
        []
    }

    func purchase(productID _: String) async throws -> TipPurchaseOutcome {
        .cancelled
    }

    func observeTransactionUpdates(
        onVerifiedTransaction _: @escaping @Sendable (String) async -> Void
    ) -> Task<Void, Never> {
        self.observationTask
    }
}
