//
//  ForecastListSnapshot.swift
//  EstonianWeather
//

import UIKit
import WeatherCore

nonisolated enum ForecastListSection: Hashable, Sendable {
    /// A forecast day, identified by `ForecastConfiguration.id`.
    case forecast(UUID)
    case disclaimer
}

nonisolated enum ForecastListItem: Hashable, Sendable {
    /// The night part of the forecast with this `ForecastConfiguration.id`.
    case night(UUID)
    /// The day part of the forecast with this `ForecastConfiguration.id`.
    case day(UUID)
    case disclaimer
}

nonisolated enum ForecastListSnapshot {
    /// One section per forecast day (night, then day), followed by the disclaimer section if requested.
    static func make(
        forecasts: [ForecastConfiguration],
        includesDisclaimer: Bool
    ) -> NSDiffableDataSourceSnapshot<ForecastListSection, ForecastListItem> {
        var snapshot = NSDiffableDataSourceSnapshot<ForecastListSection, ForecastListItem>()

        for forecast in forecasts {
            snapshot.appendSections([.forecast(forecast.id)])
            snapshot.appendItems([.night(forecast.id), .day(forecast.id)])
        }

        if includesDisclaimer {
            snapshot.appendSections([.disclaimer])
            snapshot.appendItems([.disclaimer])
        }

        return snapshot
    }
}
