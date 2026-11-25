//
//  RootNavigationView.swift
//  EstonianWeather
//

import SwiftUI

struct RootNavigationView: View {
    @State private var selectedTab = AppTab.defaultTab

    let tipJarStore: TipJarStore

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ForEach(AppTab.allCases) { tab in
                Tab(value: tab) {
                    NavigationStack {
                        self.destination(for: tab)
                    }
                } label: {
                    Label {
                        Text(tab.titleResource)
                    } icon: {
                        Image(systemName: tab.systemImageName)
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    @ViewBuilder
    private func destination(for tab: AppTab) -> some View {
        switch tab {
        case .forecasts:
            ForecastListView()
        case .settings:
            SettingsView(tipJarStore: self.tipJarStore)
        }
    }
}

#Preview("iPhone") {
    RootNavigationView(tipJarStore: TipJarStore())
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    RootNavigationView(tipJarStore: TipJarStore())
        .environment(\.horizontalSizeClass, .regular)
}
