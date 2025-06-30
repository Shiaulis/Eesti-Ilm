//
//  ForecastListViewModel.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 13.01.2020.
//

import Foundation
import Combine
import CoreData
import UIKit
import WeatherKit

@Observable
final class ForecastListViewModel {

    enum SyncStatus: Sendable {
        case ready(displayItems: [ForecastDisplayItem])
        case refreshing
        case failed(errorMessage: String)
    }

    private(set) var syncStatus: SyncStatus = .refreshing

    private let model: WeatherService
    private var disposables: Set<AnyCancellable> = []

    init(model: WeatherService) {
        self.model = model

        Task { await fetchRemoteForecasts() }
        subscribeForNotifications()
    }

    func fetchRemoteForecasts() async {
        do {
            let displayItems = try await self.model.forecasts()
            self.syncStatus = .ready(displayItems: displayItems)
        }
        catch {
            self.syncStatus = .failed(errorMessage: error.localizedDescription)
        }
    }

    private func subscribeForNotifications() {
        NotificationCenter
            .default
            .publisher(for: UIApplication.significantTimeChangeNotification)
            .sink { _ in
                Task { [weak self] in await self?.fetchRemoteForecasts() }
            }
            .store(in: &self.disposables)
    }

}
