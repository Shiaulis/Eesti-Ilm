//
//  SettingsView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 22.01.2020.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section {
                LanguageCell(
                    currentLanguage: self.viewModel.currentLanguageName,
                    didSelected: self.viewModel.openApplicationSettings
                )
            }

            Section {
                NavigationLink(destination: AboutMeView()) {
                    Text(L10n.Strings.aboutMeTitle)
                }
                List {
                    ForEach(0 ..< self.viewModel.products.count, id: \.self) { column in
                        let product = self.viewModel.products[column]

                        Button(description(for: product)) {
                            self.viewModel.makePurchase(for: product)
                        }
                    }
                }
            }

            Section {
                DisclaimerCell(
                    disclaimerText: self.viewModel.sourceDisclaimerText,
                    url: self.viewModel.sourceDisclaimerURL,
                    urlDescription: self.viewModel.urlDescription
                )
            }
        }
        .navigationBarTitle(L10n.Strings.settings)
        .navigationBarTitleDisplayMode(.large)
        .onDisappear(perform: {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                self.viewModel.makeAttemptToShowRating(in: scene)
            }

        })
    }

    private func description(for product: StoreKit.Product) -> String {
        product.displayName + " " + product.displayPrice
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let keyValueStorage = KeyValueStorage()
        let ratingService = UserRatingService(keyValueStorage: keyValueStorage)
        let settingsViewModel = SettingsViewModel(ratingService: ratingService)
        return SettingsView(viewModel: settingsViewModel)
    }
}
