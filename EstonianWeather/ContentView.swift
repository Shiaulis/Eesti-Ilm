//
//  ContentView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 04.07.2025.
//

import SwiftUI

// MARK: - Color Palette
struct WeatherColors {
    // Primary gradient colors (inspired by app icon)
    static let primaryBlue = Color(red: 0.4, green: 0.7, blue: 1.0)      // Bright blue from icon top
    static let primaryIndigo = Color(red: 0.5, green: 0.4, blue: 0.9)    // Purple-blue from icon middle
    static let primaryPink = Color(red: 0.9, green: 0.5, blue: 0.7)      // Pink from icon bottom

    // Weather phenomenon colors
    static let sunOrange = Color(red: 1.0, green: 0.6, blue: 0.2)        // Sun orange from icon
    static let cloudGray = Color(red: 0.85, green: 0.85, blue: 0.9)      // Cloud white-gray from icon
    static let rainCyan = Color(red: 0.3, green: 0.7, blue: 0.9)         // Rain blue
    static let fogGray = Color(red: 0.7, green: 0.7, blue: 0.8)          // Fog gray
    static let mistLavender = Color(red: 0.8, green: 0.75, blue: 0.9)    // Mist lavender

    // UI accent colors
    static let temperatureBlue = Color(red: 0.2, green: 0.6, blue: 0.95) // Temperature readings
    static let windCyan = Color(red: 0.2, green: 0.8, blue: 0.9)         // Wind speed
    static let locationGreen = Color(red: 0.3, green: 0.8, blue: 0.5)    // Location markers

    // UI backgrounds
    static let cardBackground = Color(.systemBackground)
    static let sectionBackground = Color(.systemGray6)
    static let dividerColor = Color(.separator)

    // Text colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    // Background gradients
    static var appGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryBlue, primaryPink]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var headerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryBlue, primaryIndigo]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension Array where Element == Forecast {

    static let sampleForecasts: [Forecast] = [
        Forecast(
            date: "2025-07-09",
            night: DayPart(
                phenomenon: "Fog",
                minimalTemperature: 9,
                maximalTemperature: 15,
                text: "Muutliku pilvisusega ilm. Mandril sajab kohati hoovihma.",
                places: [
                    Place(name: "Harku", phenomenon: "Clear", minimalTemperature: 12, maximalTemperature: nil),
                    Place(name: "Jõhvi", phenomenon: "Few clouds", minimalTemperature: 11, maximalTemperature: nil),
                    Place(name: "Tartu", phenomenon: "Light shower", minimalTemperature: 12, maximalTemperature: nil),
                    Place(name: "Pärnu", phenomenon: "Mist", minimalTemperature: 15, maximalTemperature: nil)
                ],
                winds: [
                    Wind(name: "Kuusiku", direction: "Northerly winds", minimalSpeed: 1, maximalSpeed: 4, gust: ""),
                    Wind(name: "Väike-Maarja", direction: "Northerly winds", minimalSpeed: 1, maximalSpeed: 4, gust: "")
                ],
                sea: "Ilmaprognoos Läänemere kohta 24 tunniks. Nähtavus hea.",
                lake: "Puhub põhjakaare tuul 1-6 m/s. Laine kõrgus 0,3-0,9 m."
            ),
            day: DayPart(
                phenomenon: "Fog",
                minimalTemperature: 9,
                maximalTemperature: 15,
                text: "Muutliku pilvisusega ilm. Mandril sajab kohati hoovihma.",
                places: [
                    Place(name: "Harku", phenomenon: "Clear", minimalTemperature: 12, maximalTemperature: nil),
                    Place(name: "Jõhvi", phenomenon: "Few clouds", minimalTemperature: 11, maximalTemperature: nil),
                    Place(name: "Tartu", phenomenon: "Light shower", minimalTemperature: 12, maximalTemperature: nil),
                    Place(name: "Pärnu", phenomenon: "Mist", minimalTemperature: 15, maximalTemperature: nil)
                ],
                winds: [
                    Wind(name: "Kuusiku", direction: "Northerly winds", minimalSpeed: 1, maximalSpeed: 4, gust: ""),
                    Wind(name: "Väike-Maarja", direction: "Northerly winds", minimalSpeed: 1, maximalSpeed: 4, gust: "")
                ],
                sea: "Ilmaprognoos Läänemere kohta 24 tunniks. Nähtavus hea.",
                lake: "Puhub põhjakaare tuul 1-6 m/s. Laine kõrgus 0,3-0,9 m."
            )
        ),
        Forecast(
            date: "2025-07-10",
            night: DayPart(
                phenomenon: "Moderate shower",
                minimalTemperature: 11,
                maximalTemperature: 16,
                text: "Pilves selgimistega ilm. Mitmel pool sajab vihma.",
                places: nil,
                winds: nil,
                sea: nil,
                lake: nil
            ),
            day: DayPart(
                phenomenon: "Moderate shower",
                minimalTemperature: 11,
                maximalTemperature: 16,
                text: "Pilves selgimistega ilm. Mitmel pool sajab vihma.",
                places: nil,
                winds: nil,
                sea: nil,
                lake: nil
            )
        ),
        Forecast(
            date: "2025-07-11",
            night: DayPart(
                phenomenon: "Light shower",
                minimalTemperature: 12,
                maximalTemperature: 16,
                text: "Pilves selgimistega ilm. Mitmel pool sajab hoovihma.",
                places: nil,
                winds: nil,
                sea: nil,
                lake: nil
            ),
            day: DayPart(
                phenomenon: "Light shower",
                minimalTemperature: 12,
                maximalTemperature: 16,
                text: "Pilves selgimistega ilm. Mitmel pool sajab hoovihma.",
                places: nil,
                winds: nil,
                sea: nil,
                lake: nil
            )
        )
    ]
}

// MARK: - Data Models
struct Forecast {
    let date: String
    let night: DayPart
    let day: DayPart
}

struct DayPart {
    let phenomenon: String
    let minimalTemperature: Int
    let maximalTemperature: Int
    let text: String
    let places: [Place]?
    let winds: [Wind]?
    let sea: String?
    let lake: String?
}

struct Place {
    let name: String
    let phenomenon: String
    let minimalTemperature: Int?
    let maximalTemperature: Int?
}

struct Wind {
    let name: String
    let direction: String
    let minimalSpeed: Int
    let maximalSpeed: Int
    let gust: String?
}

// MARK: - Main Weather View
struct WeatherForecastView: View {
    let forecasts: [Forecast]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(forecasts.indices, id: \.self) { index in
                        ForecastDayView(forecast: forecasts[index])
                    }
                }
                .padding()
            }
            .background(WeatherColors.appGradient.ignoresSafeArea())
            .navigationTitle("Weather Forecast")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Single Day Forecast View
struct ForecastDayView: View {
    let forecast: Forecast

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Header with gradient background
            HStack {
                Text(formattedDate(forecast.date))
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(forecast.day.minimalTemperature)°–\(forecast.day.maximalTemperature)°")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.gray).opacity(0.2))
            .cornerRadius(12)

            // Night and Day Parts
            HStack(spacing: 16) {
                DayPartView(dayPart: forecast.night, title: "Night")

                Divider()
                    .background(WeatherColors.dividerColor)

                DayPartView(dayPart: forecast.day, title: "Day")
            }

            // Places if available
            if let places = forecast.day.places, !places.isEmpty {
                PlacesView(places: places)
            }

            // Winds if available
            if let winds = forecast.day.winds, !winds.isEmpty {
                WindsView(winds: winds)
            }

            // Sea conditions if available
            if let sea = forecast.day.sea, !sea.isEmpty {
                SeaConditionsView(text: sea)
            }
        }
        .padding()
        .background(WeatherColors.cardBackground.opacity(0.5))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }

        return dateString
    }
}

// MARK: - Day Part View (Night/Day)
struct DayPartView: View {
    let dayPart: DayPart
    let title: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.secondaryText)

            Text(dayPart.phenomenon)
                .font(.body)
                .foregroundColor(WeatherColors.primaryText)

            Text("\(dayPart.minimalTemperature)°–\(dayPart.maximalTemperature)°")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(WeatherColors.temperatureBlue)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Places View
struct PlacesView: View {
    let places: [Place]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Local Conditions")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.secondaryText)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(places.indices, id: \.self) { index in
                    PlaceView(place: places[index])
                }
            }
        }
        .padding()
        .background(WeatherColors.sectionBackground)
        .cornerRadius(12)
    }
}

// MARK: - Individual Place View
struct PlaceView: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.primaryText)

            Text(place.phenomenon)
                .font(.caption2)
                .foregroundColor(WeatherColors.secondaryText)

            if let temp = place.minimalTemperature {
                Text("\(temp)°")
                    .font(.caption)
                    .foregroundColor(WeatherColors.temperatureBlue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(WeatherColors.cardBackground)
        .cornerRadius(8)
    }
}

// MARK: - Winds View
struct WindsView: View {
    let winds: [Wind]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Wind Conditions")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.secondaryText)

            ForEach(winds.indices, id: \.self) { index in
                WindView(wind: winds[index])
            }
        }
        .padding()
        .background(WeatherColors.sectionBackground)
        .cornerRadius(12)
    }
}

// MARK: - Individual Wind View
struct WindView: View {
    let wind: Wind

    var body: some View {
        HStack {
            Text(wind.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.primaryText)

            Spacer()

            Text(wind.direction)
                .font(.caption2)
                .foregroundColor(WeatherColors.secondaryText)

            Text("\(wind.minimalSpeed)-\(wind.maximalSpeed) m/s")
                .font(.caption)
                .foregroundColor(WeatherColors.windCyan)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Sea Conditions View
struct SeaConditionsView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sea Conditions")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(WeatherColors.secondaryText)

            Text(text)
                .font(.caption)
                .foregroundColor(WeatherColors.primaryText)
                .lineLimit(nil)
        }
        .padding()
        .background(WeatherColors.sectionBackground)
        .cornerRadius(8)
    }
}

// MARK: - Preview with Dummy Data
struct WeatherForecastView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherForecastView(forecasts: .sampleForecasts)
    }
}
