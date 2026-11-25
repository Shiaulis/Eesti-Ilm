//
//  SettingsView.swift
//  EstonianWeather
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL

    private let tipJarStore: TipJarStore
    private let preferredLocalizations: [String]

    init(
        tipJarStore: TipJarStore,
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations
    ) {
        self.tipJarStore = tipJarStore
        self.preferredLocalizations = preferredLocalizations
    }

    var body: some View {
        Form {
            self.languageSection
            self.aboutAndSupportSection
            TipJarSection(store: self.tipJarStore)
            self.disclaimerSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await self.tipJarStore.loadProducts()
        }
    }

    // MARK: - Sections

    private var languageSection: some View {
        Section {
            LanguageRow(
                currentLanguage: SettingsConfiguration.currentLanguageDisplayName(
                    locale: self.locale,
                    preferredLocalizations: self.preferredLocalizations
                ),
                action: self.openAppSettings
            )
        }
    }

    private var aboutAndSupportSection: some View {
        Section {
            NavigationLink {
                AboutMeView()
            } label: {
                Text("About me")
            }
        }
    }

    @ViewBuilder
    private var disclaimerSection: some View {
        if let disclaimerURL = SettingsConfiguration.sourceDisclaimerURL(
            locale: self.locale,
            preferredLocalizations: self.preferredLocalizations
        ) {
            Section {
                SourceDisclaimerRow(
                    url: disclaimerURL,
                    urlDescription: SettingsConfiguration.sourceDisclaimerHost
                )
            }
        }
    }

    // MARK: - Actions

    private func openAppSettings() {
        guard let settingsURL = SettingsConfiguration.appSettingsURL else {
            return
        }

        self.openURL(settingsURL)
    }
}

#Preview("English") {
    NavigationStack {
        SettingsView(tipJarStore: TipJarStore(), preferredLocalizations: ["en"])
    }
    .environment(\.locale, Locale(identifier: "en_US"))
}

#Preview("Estonian") {
    NavigationStack {
        SettingsView(tipJarStore: TipJarStore(), preferredLocalizations: ["et"])
    }
    .environment(\.locale, Locale(identifier: "et_EE"))
}
