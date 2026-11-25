//
//  EstonianWeatherWidgetEntryView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 26.07.2025.
//

import SwiftUI
import WeatherCore
import WidgetKit

struct EstonianWeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ForecastTimelineEntry

    var body: some View {
        Group {
            if self.entry.forecasts.isEmpty {
                NoDataView()
            }
            else {
                switch self.family {
                case .systemSmall:
                    if let todayForecast = self.entry.forecasts.first {
                        SmallForecastView(forecast: todayForecast)
                    }
                case .systemMedium:
                    MediumForecastView(forecasts: Array(self.entry.forecasts.prefix(4)))
                default:
                    NoDataView()
                }
            }
        }
        .redacted(reason: self.entry.isPlaceholder ? .placeholder : [])
    }
}

private struct SmallForecastView: View {
    let forecast: ForecastConfiguration

    var body: some View {
        VStack(spacing: 4) {
            Text(WidgetDateFormatter.smallDateText(for: self.forecast.date))
                .font(.caption)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Spacer(minLength: 2)

            Image(systemName: WeatherPhenomenonIcon.symbolName(for: self.forecast.day.phenomenon))
                .font(.system(size: 36))
                .symbolRenderingMode(.hierarchical)
                .minimumScaleFactor(0.5)

            Spacer(minLength: 2)

            Text(self.forecast.day.temperatureRange.formattedRange)
                .font(.title2.weight(.semibold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(self.forecast.day.phenomenon)
                .font(.caption)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MediumForecastView: View {
    let forecasts: [ForecastConfiguration]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(self.forecasts.enumerated()), id: \.element.id) { index, forecast in
                if index > 0 {
                    Divider()
                        .padding(.vertical, 8)
                }
                ForecastDayColumnView(forecast: forecast)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ForecastDayColumnView: View {
    let forecast: ForecastConfiguration

    var body: some View {
        VStack(spacing: 4) {
            Text(WidgetDateFormatter.mediumDateText(for: self.forecast.date))
                .font(.caption)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Spacer(minLength: 2)

            Image(systemName: WeatherPhenomenonIcon.symbolName(for: self.forecast.day.phenomenon))
                .font(.system(size: 28))
                .symbolRenderingMode(.hierarchical)
                .minimumScaleFactor(0.5)

            Spacer(minLength: 2)

            Text(self.forecast.day.temperatureRange.formattedRange)
                .font(.callout.weight(.semibold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(self.forecast.day.phenomenon)
                .font(.caption2)
                .minimumScaleFactor(0.6)
                .lineLimit(3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 4)
    }
}

private struct NoDataView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "cloud.slash")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No data available")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
