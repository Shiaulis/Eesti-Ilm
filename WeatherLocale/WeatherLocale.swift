//
//  WeatherLocale.swift
//  WeatherLocale
//
//  Created by Andrius Shiaulis on 09.07.2022.
//

import Foundation

public enum WeatherLocale {
    case estonian, english, russian

    public init?(locale: Locale) {
        switch locale.language.languageCode?.identifier {
        case "en": self = .english
        case "ru": self = .russian
        case "et": self = .estonian
        default: return nil
        }
    }
}
