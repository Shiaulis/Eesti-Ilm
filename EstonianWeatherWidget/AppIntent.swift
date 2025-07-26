//
//  AppIntent.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 13.07.2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Eesti Ilm" }
    static var description: IntentDescription { "Get forecast for the weather in Estonia." }
}
