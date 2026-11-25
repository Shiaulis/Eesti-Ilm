//
//  AppTab.swift
//  EstonianWeather
//

import SwiftUI

nonisolated enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case forecasts
    case settings

    static let defaultTab = Self.forecasts

    var id: Self {
        self
    }

    var titleResource: LocalizedStringResource {
        switch self {
        case .forecasts:
            LocalizedStringResource("Forecasts")
        case .settings:
            LocalizedStringResource("Settings")
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
