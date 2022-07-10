//
//  Logger+Extensions.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 06.07.2021.
//

import OSLog

public extension Logger {
    enum Subsystem: String {
        case mainApp
        case widget
    }

    enum Category: String {
        case rootService
        case rating
        case purchase
        case weatherModel
    }

    init(subsystem: Subsystem = .mainApp, category: Category) {
        self.init(subsystem: subsystem.rawValue, category: category.rawValue)
    }

}
