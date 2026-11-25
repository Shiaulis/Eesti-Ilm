//
//  EstonianWeatherWidgetEntryView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//

import SwiftUI
import WidgetKit

struct EstonianWeatherWidgetEntryView: View {
    let entry: ForecastTimelineProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
    }
}
