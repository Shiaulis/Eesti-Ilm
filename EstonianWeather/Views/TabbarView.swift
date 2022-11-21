//
//  TabbarView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 02.03.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import SwiftUI
import Combine
import WeatherKit

protocol TabbarViewModel {
    var selectedTab: TabItem { get }
    var forecastListViewModel: ForecastListViewModel { get }
    var settingsViewModel: SettingsViewModel { get }

    func didSwitchTo(_ tab: TabItem)
}

struct TabbarView: View {

    private var selectedTabBinding: Binding<TabItem> {
        .init {
            self.viewModel.selectedTab
        } set: { newTab in
            self.viewModel.didSwitchTo(newTab)
        }
    }

    private let viewModel: TabbarViewModel

    init(viewModel: TabbarViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            ForEach(TabItem.allCases) { tab in
                view(for: tab)
                    .tabItem { Label(tab.title, systemImage: tab.imageName) }
                    .tag(tab)
            }
        }
    }

    private func view(for tab: TabItem) -> some View {
        NavigationView {
            switch tab {
            case .forecastList: ForecastListView(viewModel: self.viewModel.forecastListViewModel)
            case .settings: SettingsView(viewModel: self.viewModel.settingsViewModel)
            }
        }
        .navigationViewStyle(.stack)
    }

}
