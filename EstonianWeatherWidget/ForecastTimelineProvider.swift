//
//  ForecastTimelineProvider.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//


import WidgetKit

struct ForecastTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ForecastTimelineEntry {
        ForecastTimelineEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ForecastTimelineEntry {
        ForecastTimelineEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ForecastTimelineEntry> {
        var entries: [ForecastTimelineEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ForecastTimelineEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
