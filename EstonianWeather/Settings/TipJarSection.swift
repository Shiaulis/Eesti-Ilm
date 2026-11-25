//
//  TipJarSection.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 25.11.2026.
//

import SwiftUI

struct TipJarSection: View {
    let store: TipJarStore

    var body: some View {
        Section {
            switch self.store.loadState {
            case .idle, .loading:
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Loading tips…")
                        .foregroundStyle(.secondary)
                }
            case let .loaded(products):
                if products.isEmpty {
                    Text("Tips are currently unavailable.")
                        .foregroundStyle(.secondary)
                }
                else {
                    ForEach(products) { product in
                        self.productRow(product)
                    }
                }
            case .failed:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unable to load tips right now.")
                        .foregroundStyle(.secondary)

                    Button("Try again") {
                        Task {
                            await self.store.loadProducts()
                        }
                    }
                }
            }
        } header: {
            Text("Tip jar")
        } footer: {
            self.bannerFooter
        }
    }

    private func productRow(_ product: TipProduct) -> some View {
        Button {
            Task {
                await self.store.purchase(product)
            }
        } label: {
            LabeledContent {
                if self.store.purchasingProductID == product.id {
                    ProgressView()
                }
                else {
                    Text(product.displayPrice)
                        .foregroundStyle(.secondary)
                }
            } label: {
                Text(product.displayName)
                    .foregroundStyle(.primary)
            }
        }
        .disabled(self.store.purchasingProductID != nil)
    }

    @ViewBuilder
    private var bannerFooter: some View {
        switch self.store.banner {
        case .thankYou:
            Label("Thank you for your support!", systemImage: "heart.fill")
                .foregroundStyle(.secondary)
        case .pending:
            Text("Purchase is pending approval.")
                .foregroundStyle(.secondary)
        case let .error(message):
            Text(message)
                .foregroundStyle(.red)
        case nil:
            EmptyView()
        }
    }
}

#Preview("Loaded") {
    let store = TipJarStore(client: PreviewTipJarClient())
    Form {
        TipJarSection(store: store)
    }
    .task {
        await store.loadProducts()
    }
}

private nonisolated struct PreviewTipJarClient: TipJarClient {
    func fetchProducts(ids _: [String]) async throws -> [TipProduct] {
        [
            TipProduct(
                id: "com.shiaulis.estonianweather.buyadrink",
                displayName: "Buy me a drink",
                description: "Support application development",
                displayPrice: "€5.49",
                price: Decimal(string: "5.49") ?? 5.49
            ),
        ]
    }

    func purchase(productID: String) async throws -> TipPurchaseOutcome {
        .purchased(productID: productID)
    }

    func observeTransactionUpdates(
        onVerifiedTransaction _: @escaping @Sendable (String) async -> Void
    ) -> Task<Void, Never> {
        Task {}
    }
}
