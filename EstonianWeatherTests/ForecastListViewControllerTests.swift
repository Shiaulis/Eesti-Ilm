//
//  ForecastListViewControllerTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import UIKit
import WeatherCore

@MainActor
struct ForecastListViewControllerTests {
    private enum TestError: LocalizedError {
        case networkUnavailable

        var errorDescription: String? {
            "Network unavailable"
        }
    }

    /// Guards EES-94: a new background view on every `updateProperties()` pass made UIKit loop on Mac and stop updating the screen.
    @Test func reusesOneBackgroundViewAndRemovesItWhenForecastsLoad() async throws {
        var fetchCount = 0
        let viewModel = ForecastListViewModel(
            languageProvider: { .english },
            fetchForecasts: { _ in
                fetchCount += 1
                if fetchCount == 1 {
                    throw TestError.networkUnavailable
                }
                return [self.makeSampleForecast()]
            }
        )
        let controller = ForecastListViewController(viewModel: viewModel, preferredLocalizations: ["en"])
        let collectionView = try self.collectionView(in: controller)

        let loadingView = try #require(collectionView.backgroundView as? UIContentUnavailableView)
        #expect((loadingView.configuration as? UIContentUnavailableConfiguration)?.text == String(localized: "Loading"))

        await viewModel.refresh()
        controller.updatePropertiesIfNeeded()

        #expect(collectionView.backgroundView === loadingView)
        #expect(
            (loadingView.configuration as? UIContentUnavailableConfiguration)?.text
                == String(localized: "Error: \(TestError.networkUnavailable.localizedDescription)")
        )

        await viewModel.refresh()
        controller.updatePropertiesIfNeeded()

        #expect(collectionView.backgroundView == nil)
        #expect(collectionView.numberOfSections == 2)
    }

    // MARK: - Helpers

    private func collectionView(in controller: ForecastListViewController) throws -> UICollectionView {
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        controller.updatePropertiesIfNeeded()
        controller.view.layoutIfNeeded()

        return try #require(
            controller.view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView
        )
    }

    private func makeSampleForecast() -> ForecastConfiguration {
        ForecastConfiguration(
            date: Date(timeIntervalSince1970: 1_764_028_800),
            night: DayPartConfiguration(
                phenomenon: "Clear",
                temperatureRange: TemperatureRange(minimum: -2, maximum: 3),
                description: "Clear night.",
                places: []
            ),
            day: DayPartConfiguration(
                phenomenon: "Few clouds",
                temperatureRange: TemperatureRange(minimum: 5, maximum: 10),
                description: "Sunny intervals.",
                places: []
            )
        )
    }
}
