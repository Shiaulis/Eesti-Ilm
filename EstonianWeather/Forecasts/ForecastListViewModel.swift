//
//  ForecastListViewModel.swift
//  EstonianWeather
//

import Foundation
import Observation
import UIKit
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
    private let now: () -> Date
    private let calendar: Calendar
    private var lastLoadDate: Date?
    private var loadTask: Task<Void, Never>?
    private var timeChangeTask: Task<Void, Never>?

    init(
        languageProvider: @escaping () -> WeatherLanguage = { .current },
        fetchForecasts: @escaping (WeatherLanguage) async throws -> [ForecastConfiguration] = { language in
            try await WeatherService().getForecasts(for: language)
        },
        now: @escaping () -> Date = { .now },
        calendar: Calendar = .autoupdatingCurrent,
        significantTimeChanges: AsyncStream<Void> = ForecastListViewModel.makeSignificantTimeChangeStream()
    ) {
        self.languageProvider = languageProvider
        self.fetchForecasts = fetchForecasts
        self.now = now
        self.calendar = calendar
        self.timeChangeTask = Task { [weak self] in
            for await _ in significantTimeChanges {
                await self?.refresh()
            }
        }
    }

    isolated deinit {
        self.timeChangeTask?.cancel()
    }

    func loadIfNeeded() async {
        guard case .loading = self.state else {
            return
        }

        await self.refresh()
    }

    func refreshIfStale() async {
        guard let lastLoadDate = self.lastLoadDate,
              !self.calendar.isDate(lastLoadDate, inSameDayAs: self.now())
        else {
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
            let requestDate = self.now()
            do {
                self.state = try await .loaded(self.fetchForecasts(language))
                self.lastLoadDate = requestDate
            }
            catch {
                self.state = .failed(error.localizedDescription)
            }
            self.loadTask = nil
        }
        self.loadTask = task
        await task.value
    }

    static func makeSignificantTimeChangeStream() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.significantTimeChangeNotification) {
                    continuation.yield()
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
