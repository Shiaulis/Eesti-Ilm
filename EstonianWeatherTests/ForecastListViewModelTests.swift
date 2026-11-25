//
//  ForecastListViewModelTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import WeatherCore

struct ForecastListViewModelTests {
    private enum TestError: LocalizedError {
        case networkUnavailable

        var errorDescription: String? {
            "Network unavailable"
        }
    }

    @Test
    @MainActor
    func initialStateIsLoading() {
        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in [] }
        )

        guard case .loading = viewModel.state else {
            Issue.record("Expected initial state to be .loading")
            return
        }
    }

    @Test
    @MainActor
    func loadIfNeededFetchesForecastsUsingProvidedLanguage() async {
        let expectedForecast = self.makeSampleForecast()
        var requestedLanguages = [WeatherLanguage]()

        let viewModel = ForecastListViewModel(
            languageProvider: { .estonian },
            fetchForecasts: { language in
                requestedLanguages.append(language)
                return [expectedForecast]
            }
        )

        await viewModel.loadIfNeeded()

        #expect(requestedLanguages == [.estonian])

        guard case let .loaded(forecasts) = viewModel.state else {
            Issue.record("Expected state to be .loaded")
            return
        }

        #expect(forecasts.count == 1)
        #expect(forecasts.first?.id == expectedForecast.id)
    }

    @Test
    @MainActor
    func loadIfNeededDoesNotRefetchOnceLoaded() async {
        var fetchCount = 0

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                return [self.makeSampleForecast()]
            }
        )

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(fetchCount == 1)
    }

    @Test
    @MainActor
    func refreshTransitionsToFailedOnErrorAndRecoversOnRetry() async {
        var shouldFail = true
        var fetchCount = 0
        let recoveredForecast = self.makeSampleForecast()

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                if shouldFail {
                    throw TestError.networkUnavailable
                }
                return [recoveredForecast]
            }
        )

        await viewModel.loadIfNeeded()

        guard case let .failed(errorMessage) = viewModel.state else {
            Issue.record("Expected state to be .failed")
            return
        }

        #expect(errorMessage == "Network unavailable")

        // loadIfNeeded should not automatically retry a failed state
        await viewModel.loadIfNeeded()
        #expect(fetchCount == 1)

        // Explicit refresh (retry / pull-to-refresh) should recover
        shouldFail = false
        await viewModel.refresh()

        #expect(fetchCount == 2)
        guard case let .loaded(forecasts) = viewModel.state else {
            Issue.record("Expected state to recover to .loaded")
            return
        }

        #expect(forecasts.count == 1)
        #expect(forecasts.first?.id == recoveredForecast.id)
    }

    @Test
    @MainActor
    func cancelledLoadKeepsLoadingStateAndAllowsRetry() async {
        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                try await Task.sleep(for: .seconds(60))
                return []
            }
        )

        let task = Task { @MainActor in
            await viewModel.loadIfNeeded()
        }
        task.cancel()
        await task.value

        guard case .loading = viewModel.state else {
            Issue.record("Expected cancelled load to keep state .loading")
            return
        }
    }

    @Test
    @MainActor
    func refreshReplacesLoadedForecasts() async {
        let firstForecast = self.makeSampleForecast()
        let secondForecast = self.makeSampleForecast()
        var responses: [[ForecastConfiguration]] = [[firstForecast], [secondForecast]]

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                responses.removeFirst()
            }
        )

        await viewModel.loadIfNeeded()
        await viewModel.refresh()

        guard case let .loaded(forecasts) = viewModel.state else {
            Issue.record("Expected state to be .loaded")
            return
        }

        #expect(forecasts.first?.id == secondForecast.id)
    }

    @Test
    @MainActor
    func concurrentRefreshCallsAreCoalesced() async {
        var fetchCount = 0
        let sampleForecast = self.makeSampleForecast()

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                try await Task.sleep(for: .milliseconds(50))
                return [sampleForecast]
            }
        )

        async let firstRefresh: Void = viewModel.refresh()
        async let secondRefresh: Void = viewModel.refresh()
        _ = await (firstRefresh, secondRefresh)

        #expect(fetchCount == 1)
    }

    // MARK: - Helpers

    private func makeSampleForecast() -> ForecastConfiguration {
        ForecastConfiguration(
            date: Date(timeIntervalSince1970: 1_764_028_800),
            night: DayPartConfiguration(
                phenomenon: "Clear",
                temperatureRange: TemperatureRange(minimum: -2, maximum: 3),
                description: "Clear night.",
                places: [
                    PlaceConfiguration(
                        name: "Tallinn",
                        phenomenon: "Clear",
                        temperature: .minimum(0)
                    ),
                ]
            ),
            day: DayPartConfiguration(
                phenomenon: "Few clouds",
                temperatureRange: TemperatureRange(minimum: 5, maximum: 10),
                description: "Sunny intervals.",
                places: [
                    PlaceConfiguration(
                        name: "Tallinn",
                        phenomenon: "Few clouds",
                        temperature: .maximum(9)
                    ),
                ]
            )
        )
    }
}
