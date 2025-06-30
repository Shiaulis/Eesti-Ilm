//
//  ForecastListView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 12.01.2020.
//

import SwiftUI
import WeatherKit

struct ForecastListView: View {
    // MARK: - Properties

    var viewModel: ForecastListViewModel

    // MARK: - Body

    var body: some View {
        Group {
            switch self.viewModel.syncStatus {
            case .refreshing:
                ListPlaceholder(description: L10n.Strings.loading)
            case let .ready(displayItems):
                list(for: displayItems)
            case let .failed(errorMessage):
                ListPlaceholder(
                    description: L10n.Strings.FailedToSync.error + ": " + errorMessage
                )
            }
        }
        .ifOS(.iOS) { view in
            view.refreshable { await self.viewModel.fetchRemoteForecasts() }
        }
        .navigationTitle(L10n.Strings.fourDayForecast)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func list(for displayItems: [ForecastDisplayItem]) -> some View {
        Form {
            ForEach(displayItems) { displayItem in
                Section(header: Text(displayItem.naturalDateDescription).font(.headline)) {
                    ForEach(displayItem.dayParts) { dayPart in
                        DayPartView(item: dayPart)
                    }
                }
            }
        }
    }
}

struct ListPlaceholder: View {
    let description: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(self.description)
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
    }
}

struct SettingsButton: View {
    private let tapped: () -> Void

    init(_ tapped: @escaping () -> Void) {
        self.tapped = tapped
    }

    var body: some View {
        Button(action: self.tapped) {
            Image(systemName: "gear")
        }
    }
}

extension Color {
    static let topBackgroundGradient: Color = .init("topBackgroundGradient")
    static let bottomBackgroundGradient: Color = .init("bottomBackgroundGradient")
    static let topBarColor: Color = .init("topBarColor")
    static let bottomBarColor: Color = .init("bottomBarColor")
}

extension UIColor {
    static let topBackgroundGradient: UIColor = .init(.topBackgroundGradient)
    static let bottomBackgroundGradient: UIColor = .init(.bottomBackgroundGradient)
    static let topBarColor: UIColor = .init(.topBarColor)
    static let bottomBarColor: UIColor = .init(.bottomBarColor)
}
