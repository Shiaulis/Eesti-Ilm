//
//  AppLocalization.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 22.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import Foundation

enum AppLocalization {

    // MARK: - Cases

    case english, russian, estonian, ukrainian

    // MARK: - Properties

    var languageCode: String {
        switch self {
        case .english: return "en"
        case .estonian: return "et"
        case .russian: return "ru"
        case .ukrainian: return "uk"
        }
    }

    var localizedString: String? {
        Locale.current.localizedString(forLanguageCode: self.languageCode)
    }

}
