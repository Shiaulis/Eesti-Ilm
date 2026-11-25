//
//  DayPartView.swift
//  EstonianWeather
//

import SwiftUI
import WeatherCore

struct DayPartView: View {
    enum Kind {
        case night
        case day

        var title: LocalizedStringKey {
            switch self {
            case .night: "Night"
            case .day: "Day"
            }
        }
    }

    let kind: Kind
    let dayPart: DayPartConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Text(self.kind.title)
                    .font(.title2.weight(.semibold))

                Spacer()

                Text(ForecastFormatter.temperatureRangeText(for: self.dayPart.temperatureRange))
                    .font(.title2.weight(.medium))
                    .monospacedDigit()

                Image(systemName: WeatherPhenomenonIcon.symbolName(for: self.dayPart.phenomenon))
                    .symbolRenderingMode(.multicolor)
                    .font(.title)
                    .accessibilityLabel(self.dayPart.phenomenon)
            }

            Text(self.dayPart.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            if !self.dayPart.places.isEmpty {
                Divider()

                VStack(spacing: 8) {
                    ForEach(self.dayPart.places) { place in
                        PlaceRow(place: place)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Form {
        DayPartView(
            kind: .day,
            dayPart: DayPartConfiguration(
                phenomenon: "Few clouds",
                temperatureRange: TemperatureRange(minimum: 12, maximum: 19),
                description: "Partly cloudy and mostly dry. West wind 4-9 m/s.",
                places: [
                    PlaceConfiguration(
                        name: "Tallinn",
                        phenomenon: "Few clouds",
                        temperature: .maximum(17)
                    ),
                    PlaceConfiguration(
                        name: "Tartu",
                        phenomenon: "Clear",
                        temperature: .range(TemperatureRange(minimum: 13, maximum: 19))
                    ),
                ]
            )
        )
    }
}
