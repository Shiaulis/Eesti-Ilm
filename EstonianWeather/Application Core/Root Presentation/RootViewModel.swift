//
//  RootViewModel.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import Combine
import Foundation
import NetworkModule
import WeatherKit

final class RootViewModel: SidebarViewModel, TabbarViewModel {
    // MARK: - Properties

    @Published var selectedTab: TabItem = .forecastList

    let forecastListViewModel: ForecastListViewModel
    let settingsViewModel: SettingsViewModel

    // MARK: - Init

    init(rootService: RootService) {
        self.forecastListViewModel = ForecastListViewModel(model: rootService.weatherService)
        self.settingsViewModel = SettingsViewModel(ratingService: rootService.userRatingService)
    }

    var selectedTabPublisher: AnyPublisher<TabItem, Never> { self.$selectedTab.eraseToAnyPublisher() }

    func select(_ tab: TabItem) {
        self.selectedTab = tab
    }

    func didSwitchTo(_ tab: TabItem) {
        self.selectedTab = tab
    }
}
