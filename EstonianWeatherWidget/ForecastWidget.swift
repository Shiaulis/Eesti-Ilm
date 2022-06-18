//
//  ForecastWidget.swift
//  ForecastWidget
//
//  Created by Andrius Shiaulis on 05.10.2020.
//

import WidgetKit
import SwiftUI
import Intents

struct ForecastWidget: Widget {
    let kind: String = "com.shiaulis.EstonianWeather.EstonianWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetForercastProvider()) { entry in
            EstonianWeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Forecast Widget")
        .description("Check Estonian weather forecast.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct EstonianWeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        EstonianWeatherWidgetEntryView(entry: ForecastEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
