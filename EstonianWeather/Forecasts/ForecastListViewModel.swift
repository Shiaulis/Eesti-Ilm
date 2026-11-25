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
    private var loadTask: Task<Void, Never>?

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
        // Overlapping callers join the load in flight. The fetch runs in a task owned by the model,
        // so cancelling a caller (e.g. the view's `.task`) cannot abort it or leave the state stale.
        if let loadTask = self.loadTask {
            await loadTask.value
            return
        }

        let language = self.languageProvider()
        let task = Task { @MainActor in
            do {
                self.state = try await .loaded(self.fetchForecasts(language))
            }
            catch {
                self.state = .failed(error.localizedDescription)
            }
            self.loadTask = nil
        }
        self.loadTask = task
        await task.value
    }
}
