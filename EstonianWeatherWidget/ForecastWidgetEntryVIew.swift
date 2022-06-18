//
//  ForecastWidgetEntryVIew.swift
//  EstonianWeatherWidgetExtension
//
//  Created by Andrius Shiaulis on 11.10.2020.
//

import SwiftUI
import WidgetKit
import WeatherKit

struct EstonianWeatherWidgetEntryView: View {
    let entry: ForecastEntry
    @Environment(\.widgetFamily) private var family

    private var displayItems: [ForecastDisplayItem] {
        switch self.family {
        case .systemSmall: return [self.entry.displayItems.first].compactMap { $0 }
        case .systemMedium: return self.entry.displayItems
        case .systemLarge: return []
        case .systemExtraLarge: return []
        case .accessoryCircular: return []
        case .accessoryRectangular: return []
        case .accessoryInline: return []
        @unknown default: return []
        }
    }

    var shouldShowSmallWidget: Bool {
        switch self.family {
        case .systemSmall: return true
        default: return false
        }
    }

    @ViewBuilder
    var body: some View {
        if self.family == .systemSmall {
            if !self.displayItems.isEmpty {
                ForecastFullWeatherView(displayItem: self.displayItems.first!)
            }
            else {
                PlaceholderView()
            }
        }
        else {
            if !self.displayItems.isEmpty {
                ZStack {
                    // This gives separator color
                    Color(.appRose)
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            ForEach(self.displayItems.compactMap { $0 }) { displayItem in
                                ForecastWeatherDayView(displayItem: displayItem)
                            }
                        }

                    }
                }
            }
            else {
                PlaceholderView()
            }
        }
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(NSLocalizedString("No data available", comment: ""))
                Spacer()
            }
            Spacer()
        }
    }
}

private struct HeaderView: View {

    @Environment(\.widgetFamily) private var family

    private var text: String {
        switch self.family {
        case .systemSmall: return NSLocalizedString("forecast", comment: "")
        case .systemMedium: return NSLocalizedString("estonian_weather_forecast", comment: "")
        case .systemLarge: return ""
        case .systemExtraLarge: return ""
        case .accessoryCircular: return ""
        case .accessoryRectangular: return ""
        case .accessoryInline: return ""
        @unknown default: return ""
        }
    }

    var body: some View {
        ZStack {
            Color(.appRose)
                .layoutPriority(-1)
            HStack {
                Spacer()
                Text("")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
            }
        }

    }
}

private struct ForecastFullWeatherView: View {
    let displayItem: ForecastDisplayItem

    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
            VStack {
                Text(self.displayItem.naturalDateDescription)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Spacer()
                Image(systemName: self.displayItem.day?.weatherIconName ?? "")
                    .font(.system(size: 60))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Spacer()
                Text(self.displayItem.day?.temperatureRange ?? "")
                    .font(.system(size: 24))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
            }
            .foregroundColor(Color(.label))
            .padding(16)
        }
    }
}

private struct ForecastWeatherDayView: View {
    let displayItem: ForecastDisplayItem

    var dayDisplayItem: DayPartForecastDisplayItem? {
        self.displayItem.day
    }

    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
            VStack {
                HStack {
                    Text(self.displayItem.shortDateDescription)
                        .font(.system(size: 12))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: self.dayDisplayItem?.weatherIconName ?? "")
                    .font(.system(size: 40))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                Spacer()
                Text(self.dayDisplayItem?.temperatureRange ?? "")
                    .font(.system(size: 18))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
            }
            .padding(.init(top: 16, leading: 2, bottom: 16, trailing: 2))
            .foregroundColor(Color(.label))
        }
    }
}

private struct ForecastWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EstonianWeatherWidgetEntryView(entry: .test)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            EstonianWeatherWidgetEntryView(entry: .test)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            ForecastFullWeatherView(displayItem: .test1)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)
            ForecastFullWeatherView(displayItem: .test1)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
        }
    }
}
