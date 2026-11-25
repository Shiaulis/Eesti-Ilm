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
    func cancelledCallerDoesNotLeaveOverlappingLoadStuck() async {
        let gate = Gate()
        var fetchCount = 0

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                await gate.wait()
                try Task.checkCancellation()
                return [self.makeSampleForecast()]
            }
        )

        let first = Task { @MainActor in
            await viewModel.loadIfNeeded()
        }
        while fetchCount == 0 {
            await Task.yield()
        }

        // The view disappears (cancelling its task) and reappears while the fetch is still running.
        first.cancel()
        let second = Task { @MainActor in
            await viewModel.loadIfNeeded()
        }
        await Task.yield()

        gate.open()
        await first.value
        await second.value

        #expect(fetchCount == 1)
        guard case .loaded = viewModel.state else {
            Issue.record("Expected state to be .loaded after overlapping cancelled load")
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

    @Test
    @MainActor
    func significantTimeChangeRefreshesForecasts() async {
        let firstForecast = self.makeSampleForecast()
        let secondForecast = self.makeSampleForecast()
        var responses: [[ForecastConfiguration]] = [[firstForecast], [secondForecast]]
        var fetchCount = 0
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        defer { continuation.finish() }

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                return responses.removeFirst()
            },
            significantTimeChanges: stream
        )

        await viewModel.loadIfNeeded()
        #expect(fetchCount == 1)

        continuation.yield()
        while case let .loaded(forecasts) = viewModel.state, forecasts.first?.id != secondForecast.id {
            await Task.yield()
        }

        #expect(fetchCount == 2)
        guard case let .loaded(forecasts) = viewModel.state else {
            Issue.record("Expected state to be .loaded")
            return
        }

        #expect(forecasts.first?.id == secondForecast.id)
    }

    @Test
    @MainActor
    func significantTimeChangeCoalescesWithInFlightLoad() async {
        let gate = Gate()
        var fetchCount = 0
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        defer { continuation.finish() }

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                await gate.wait()
                return [self.makeSampleForecast()]
            },
            significantTimeChanges: stream
        )

        let loadTask = Task { @MainActor in
            await viewModel.loadIfNeeded()
        }
        while fetchCount == 0 {
            await Task.yield()
        }

        continuation.yield()
        await Task.yield()

        gate.open()
        await loadTask.value

        #expect(fetchCount == 1)
    }

    @Test
    @MainActor
    func refreshIfStaleDoesNothingBeforeInitialLoad() async {
        var fetchCount = 0
        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                return [self.makeSampleForecast()]
            }
        )

        await viewModel.refreshIfStale()

        #expect(fetchCount == 0)
        guard case .loading = viewModel.state else {
            Issue.record("Expected state to remain .loading")
            return
        }
    }

    @Test
    @MainActor
    func refreshIfStaleDoesNotRefetchOnSameCalendarDay() async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var currentDate = Date(timeIntervalSince1970: 1_764_064_800) // 2025-11-25 10:00:00 UTC
        var fetchCount = 0

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                return [self.makeSampleForecast()]
            },
            now: { currentDate },
            calendar: calendar
        )

        await viewModel.loadIfNeeded()
        #expect(fetchCount == 1)

        currentDate = Date(timeIntervalSince1970: 1_764_115_140) // 2025-11-25 23:59:00 UTC
        await viewModel.refreshIfStale()

        #expect(fetchCount == 1)
    }

    @Test
    @MainActor
    func refreshIfStaleRefreshesOnLaterCalendarDay() async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var currentDate = Date(timeIntervalSince1970: 1_764_114_600) // 2025-11-25 23:50:00 UTC
        let firstForecast = self.makeSampleForecast()
        let secondForecast = self.makeSampleForecast()
        var responses: [[ForecastConfiguration]] = [[firstForecast], [secondForecast]]
        var fetchCount = 0

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                return responses.removeFirst()
            },
            now: { currentDate },
            calendar: calendar
        )

        await viewModel.loadIfNeeded()
        #expect(fetchCount == 1)

        currentDate = Date(timeIntervalSince1970: 1_764_115_500) // 2025-11-26 00:05:00 UTC
        await viewModel.refreshIfStale()

        #expect(fetchCount == 2)
        guard case let .loaded(forecasts) = viewModel.state else {
            Issue.record("Expected state to be .loaded")
            return
        }

        #expect(forecasts.first?.id == secondForecast.id)

        // Subsequent active check on the same day should not refetch again.
        currentDate = Date(timeIntervalSince1970: 1_764_144_000) // 2025-11-26 08:00:00 UTC
        await viewModel.refreshIfStale()
        #expect(fetchCount == 2)
    }

    @Test
    @MainActor
    func refreshRecordsRequestStartDateAcrossMidnight() async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var currentDate = Date(timeIntervalSince1970: 1_764_115_195) // 2025-11-25 23:59:55 UTC
        let gate = Gate()
        var fetchCount = 0

        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                if fetchCount == 1 {
                    await gate.wait()
                }
                return [self.makeSampleForecast()]
            },
            now: { currentDate },
            calendar: calendar
        )

        let loadTask = Task { @MainActor in
            await viewModel.loadIfNeeded()
        }
        while fetchCount == 0 {
            await Task.yield()
        }

        // Midnight passes while the initial fetch is in flight.
        currentDate = Date(timeIntervalSince1970: 1_764_115_205) // 2025-11-26 00:00:05 UTC
        gate.open()
        await loadTask.value

        #expect(fetchCount == 1)

        // Because the first request started before midnight, the foreground check on the new day refreshes.
        await viewModel.refreshIfStale()
        #expect(fetchCount == 2)
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

@MainActor
private final class Gate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isOpen = false

    func wait() async {
        guard !self.isOpen else {
            return
        }

        await withCheckedContinuation { self.continuation = $0 }
    }

    func open() {
        self.isOpen = true
        self.continuation?.resume()
        self.continuation = nil
    }
}
