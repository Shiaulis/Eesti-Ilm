//
//  RootViewModel.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import Foundation
import WeatherKit
import Combine
import NetworkModule

final class RootViewModel {

    // MARK: - Properties
    @Published var selectedTab: TabItem = .forecastList

    let forecastListViewModel: ForecastListViewModel
    let settingsViewModel: SettingsViewModel

    // MARK: - Init

    init(rootService: RootService) {
        self.forecastListViewModel = ForecastListViewModel(model: rootService.weatherModel)
        self.settingsViewModel = SettingsViewModel(ratingService: rootService.ratingService)
    }

}

extension RootViewModel: SidebarViewModel {

    var selectedTabPublisher: AnyPublisher<TabItem, Never> { self.$selectedTab.eraseToAnyPublisher() }

    func select(_ tab: TabItem) {
        self.selectedTab = tab
    }

}

extension RootViewModel: TabbarViewModel {

    func didSwitchTo(_ tab: TabItem) {
        self.selectedTab = tab
    }

}
