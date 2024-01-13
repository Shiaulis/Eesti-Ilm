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
        .configurationDisplayName(L10n.Strings.forecastWidget)
        .description(L10n.Strings.checkEstonianWeatherForecast)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct EstonianWeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        EstonianWeatherWidgetEntryView(entry: ForecastEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
