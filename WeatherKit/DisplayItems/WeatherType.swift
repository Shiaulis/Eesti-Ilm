//
//  WeatherType.swift
//
//
//  Created by Andrius Shiaulis on 20.03.2021.
//

import Foundation

enum WeatherType: String {
    // MARK: - Properties

    var imageName: String? {
        switch self {
        case .clear:
            "sun.max"
        case .fewClouds:
            "cloud.sun"
        case .variableClouds:
            "cloud.sun"
        case .cloudyWithClearSpells:
            "cloud.sun"
        case .cloudy:
            "smoke"
        case .lightSnowShower:
            "cloud.snow"
        case .moderateSnowShower:
            "cloud.snow"
        case .heavySnowShower:
            "cloud.snow"
        case .lightShower:
            "cloud.drizzle"
        case .moderateShower:
            "cloud.rain"
        case .heavyShower:
            "cloud.heavyrain"
        case .lightRain:
            "cloud.drizzle"
        case .moderateRain:
            "cloud.rain"
        case .heavyRain:
            "cloud.heavyrain"
        case .riskOfGlaze:
            "thermometer.snowflake"
        case .lightSleet:
            "cloud.sleet"
        case .moderateSleet:
            "cloud.sleet"
        case .lightSnowfall:
            "cloud.snow"
        case .moderateSnowfall:
            "cloud.snow"
        case .heavySnowfall:
            "cloud.snow"
        case .snowstorm:
            "cloud.snow"
        case .driftingSnow:
            "cloud.snow"
        case .hail:
            "cloud.hail"
        case .mist:
            "cloud.fog"
        case .fog:
            "cloud.fog"
        case .thunder:
            "wind"
        case .thunderstorm:
            "wind"
        }
    }

    // MARK: - Init

    init?(phenomenonName: String?) {
        guard let name = phenomenonName else { return nil }

        self.init(rawValue: name)
    }

    // MARK: - Cases

    case clear = "Clear"
    case fewClouds = "Few clouds"
    case variableClouds = "Variable clouds"
    case cloudyWithClearSpells = "Cloudy with clear spells"
    case cloudy = "Cloudy"
    case lightSnowShower = "Light snow shower"
    case moderateSnowShower = "Moderate snow shower"
    case heavySnowShower = "Heavy snow shower"
    case lightShower = "Light shower"
    case moderateShower = "Moderate shower"
    case heavyShower = "Heavy shower"
    case lightRain = "Light rain"
    case moderateRain = "Moderate rain"
    case heavyRain = "Heavy rain"
    case riskOfGlaze = "Risk of glaze"
    case lightSleet = "Light sleet"
    case moderateSleet = "Moderate sleet"
    case lightSnowfall = "Light snowfall"
    case moderateSnowfall = "Moderate snowfall"
    case heavySnowfall = "Heavy snowfall"
    case snowstorm = "Snowstorm"
    case driftingSnow = "Drifting snow"
    case hail = "Hail"
    case mist = "Mist"
    case fog = "Fog"
    case thunder = "Thunder"
    case thunderstorm = "Thunderstorm"
}
