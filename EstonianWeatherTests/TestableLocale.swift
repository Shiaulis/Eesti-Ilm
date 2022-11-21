//
//  TestableLocale.swift
//  EstonianWeatherTests
//
//  Created by Andrius Shiaulis on 10.10.2020.
//

import Foundation
@testable import EstonianWeather

enum TestableLocale: String {
    case english, estonian, russian, anyOther

    static let current: TestableLocale = .init(from: .current)

    private init(from locale: Locale) {
        switch locale.language.languageCode?.identifier {
        case "en": self = .english
        case "et": self = .estonian
        case "ru": self = .russian
        default: self = .anyOther
        }
    }

}
