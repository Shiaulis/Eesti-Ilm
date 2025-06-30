//
//  ForecastWidget.swift
//  ForecastWidget
//
//  Created by Andrius Shiaulis on 05.10.2020.
//

import Intents
import SwiftUI
import WidgetKit

struct ForecastWidget: Widget {
    let kind: String = "com.shiaulis.EstonianWeather.EstonianWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetForecastProvider()) { entry in
            EstonianWeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Forecast Widget"))
        .description(String(localized: "Check Estonian weather forecast"))
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

struct EstonianWeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        EstonianWeatherWidgetEntryView(entry: ForecastEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
