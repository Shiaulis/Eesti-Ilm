//
//  EstonianWeatherWidget.swift
//  EstonianWeatherWidget
//
//  Created by Andrius Shiaulis on 13.07.2025.
//

import SwiftUI
import WidgetKit

struct EstonianWeatherWidget: Widget {
    let kind = "com.shiaulis.EstonianWeather.EstonianWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: self.kind, provider: ForecastTimelineProvider()) { entry in
            EstonianWeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Forecast Widget")
        .description("Check Estonian weather forecast.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    EstonianWeatherWidget()
} timeline: {
    ForecastTimelineEntry.preview
    ForecastTimelineEntry.empty
}

#Preview(as: .systemMedium) {
    EstonianWeatherWidget()
} timeline: {
    ForecastTimelineEntry.preview
    ForecastTimelineEntry.empty
}
