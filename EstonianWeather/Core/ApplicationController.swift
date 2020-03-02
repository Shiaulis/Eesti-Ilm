//
//  ApplicationController.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 02.03.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import Foundation

final class ApplicationController {

    private let mainService: MainService

    init() {
        self.mainService = .init()
    }
}

extension ApplicationController: ApplicationViewModel {

    private var isUnitTesting: Bool { ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil }

    var applicationMode: ApplicationMode {
        if self.isUnitTesting {
            return .unitTests
        }

        return .swiftUI
    }

    func forecastDataProvider() -> ForecastDataProvider {
        ForecastDataProvider()
    }

}
