//
//  AppTab.swift
//  EstonianWeather
//

import Foundation

nonisolated enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case forecasts
    case settings

    static let defaultTab = Self.forecasts

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .forecasts:
            String(localized: "Forecasts")
        case .settings:
            String(localized: "Settings")
        }
    }

    var systemImageName: String {
        switch self {
        case .forecasts:
            "cloud.sun"
        case .settings:
            "gear"
        }
    }
}
