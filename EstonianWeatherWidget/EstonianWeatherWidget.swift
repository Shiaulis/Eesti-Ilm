//
//  EstonianWeatherWidget.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 13.07.2025.
//

import WidgetKit
import SwiftUI

struct EstonianWeatherWidget: Widget {
    let kind: String = "Eesti Ilm"
    let provider = ForecastTimelineProvider()

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ForecastIntent.self, provider: self.provider) { entry in
            EstonianWeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    EstonianWeatherWidget()
} timeline: {
    ForecastTimelineEntry(date: .now, configuration: .init())
}


#Preview(as: .systemMedium) {
    EstonianWeatherWidget()
} timeline: {
    ForecastTimelineEntry(date: .now, configuration: .init())
}
