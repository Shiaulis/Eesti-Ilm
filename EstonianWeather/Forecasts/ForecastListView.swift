//
//  ForecastListView.swift
//  EstonianWeather
//

import SwiftUI
import WeatherCore

struct ForecastListView: View {
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: ForecastListViewModel

    private let preferredLocalizations: [String]

    init(
        viewModel: ForecastListViewModel = ForecastListViewModel(),
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.preferredLocalizations = preferredLocalizations
    }

    var body: some View {
        Group {
            switch self.viewModel.state {
            case .loading:
                self.loadingView
            case let .loaded(forecasts):
                self.forecastList(for: forecasts)
            case let .failed(errorMessage):
                self.errorView(message: errorMessage)
            }
        }
        .navigationTitle("Forecasts")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await self.viewModel.refresh()
        }
        .task {
            await self.viewModel.loadIfNeeded()
        }
        .task(id: self.scenePhase) {
            guard self.scenePhase == .active else {
                return
            }

            await self.viewModel.refreshIfStale()
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Error: \(message)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task {
                        await self.viewModel.refresh()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
        }
    }

    private func forecastList(for forecasts: [ForecastConfiguration]) -> some View {
        Form {
            ForEach(forecasts) { forecast in
                Section {
                    DayPartView(kind: .night, dayPart: forecast.night)
                    DayPartView(kind: .day, dayPart: forecast.day)
                } header: {
                    Text(ForecastFormatter.sectionTitle(for: forecast.date, locale: self.locale))
                        .font(.headline)
                }
            }

            if let disclaimerURL = SettingsConfiguration.sourceDisclaimerURL(
                locale: self.locale,
                preferredLocalizations: self.preferredLocalizations
            ) {
                Section {
                    SourceDisclaimerRow(
                        url: disclaimerURL,
                        urlDescription: SettingsConfiguration.sourceDisclaimerHost
                    )
                }
            }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        ForecastListView(
            viewModel: ForecastListViewModel(
                fetchForecasts: { _ in
                    [
                        ForecastConfiguration(
                            date: .now,
                            night: DayPartConfiguration(
                                phenomenon: "Clear",
                                temperatureRange: TemperatureRange(minimum: 4, maximum: 9),
                                description: "Clear and calm night.",
                                places: [
                                    PlaceConfiguration(
                                        name: "Tallinn",
                                        phenomenon: "Clear",
                                        temperature: .minimum(6)
                                    ),
                                ]
                            ),
                            day: DayPartConfiguration(
                                phenomenon: "Few clouds",
                                temperatureRange: TemperatureRange(minimum: 14, maximum: 20),
                                description: "Mostly sunny with light southerly wind.",
                                places: [
                                    PlaceConfiguration(
                                        name: "Tallinn",
                                        phenomenon: "Few clouds",
                                        temperature: .maximum(18)
                                    ),
                                ]
                            )
                        ),
                    ]
                }
            )
        )
    }
}
