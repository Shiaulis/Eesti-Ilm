//
//  PlaceRow.swift
//  EstonianWeather
//

import SwiftUI
import WeatherCore

struct PlaceRow: View {
    let place: PlaceConfiguration

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var iconColumnWidth: CGFloat = 22

    var body: some View {
        HStack(spacing: 12) {
            Text(self.place.name)
                .font(.subheadline)

            Spacer()

            Image(systemName: WeatherPhenomenonIcon.symbolName(for: self.place.phenomenon))
                .symbolRenderingMode(.multicolor)
                .frame(
                    minWidth: self.iconColumnWidth,
                    maxWidth: self.dynamicTypeSize.isAccessibilitySize ? nil : self.iconColumnWidth
                )
                .fixedSize()
                .accessibilityLabel(self.place.phenomenon)

            if let temperatureText = ForecastFormatter.placeTemperatureText(for: self.place.temperature) {
                Text(temperatureText)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, alignment: .trailing)
            }
        }
    }
}

#Preview {
    Form {
        PlaceRow(
            place: PlaceConfiguration(
                name: "Tallinn",
                phenomenon: "Few clouds",
                temperature: .range(TemperatureRange(minimum: 2, maximum: 7))
            )
        )
        PlaceRow(
            place: PlaceConfiguration(
                name: "Tartu",
                phenomenon: "Light rain",
                temperature: .minimum(-1)
            )
        )
    }
}
