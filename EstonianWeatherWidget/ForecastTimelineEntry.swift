//
//  ForecastTimelineEntry.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//

import WidgetKit

struct ForecastTimelineEntry: TimelineEntry {
    let date: Date
    let configuration: ForecastIntent
}
