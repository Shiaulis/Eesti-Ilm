//
//  ForecastListViewModel.swift
//  EstonianWeather
//

import Foundation
import Observation
import WeatherCore

@MainActor
@Observable
final class ForecastListViewModel {
    enum State {
        case loading
        case loaded([ForecastConfiguration])
        case failed(String)
    }

    private(set) var state = State.loading

    private let languageProvider: () -> WeatherLanguage
    private let fetchForecasts: (WeatherLanguage) async throws -> [ForecastConfiguration]
    private var isFetching = false

    init(
        languageProvider: @escaping () -> WeatherLanguage = { .current },
        fetchForecasts: @escaping (WeatherLanguage) async throws -> [ForecastConfiguration] = { language in
            try await WeatherService().getForecasts(for: language)
        }
    ) {
        self.languageProvider = languageProvider
        self.fetchForecasts = fetchForecasts
    }

    func loadIfNeeded() async {
        guard case .loading = self.state else {
            return
        }

        await self.refresh()
    }

    func refresh() async {
        guard !self.isFetching else {
            return
        }

        self.isFetching = true
        defer { self.isFetching = false }

        do {
            let language = self.languageProvider()
            let forecasts = try await self.fetchForecasts(language)
            self.state = .loaded(forecasts)
        }
        catch {
            // A cancelled load (e.g. the view disappeared) is not a failure: keep the previous state.
            guard !Task.isCancelled else {
                return
            }

            self.state = .failed(error.localizedDescription)
        }
    }
}
