//
//  TabItem.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import Foundation

enum TabItem: Int, CaseIterable, Identifiable {
    var id: RawValue { self.rawValue }

    case forecastList, settings

    var title: String {
        switch self {
        case .forecastList: return String(localized: "Forecast")
        case .settings: return String(localized: "Settings")
        }
    }

    var imageName: String {
        switch self {
        case .forecastList: return "cloud.sun"
        case .settings: return "gear"
        }
    }

    var indexPath: IndexPath {
        .init(row: self.rawValue, section: 0)
    }
}
