//
//  ForecastListView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 12.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import SwiftUI
import WeatherKit

struct ForecastListView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ForecastListViewModel

    // MARK: - Body

    var body: some View {
        Group {
            switch self.viewModel.syncStatus {
            case .refreshing:
                ListPlaceholder(description: R.string.localizable.loading())
            case .ready(let displayItems):
                list(for: displayItems)
            case .failed(let errorMessage):
                ListPlaceholder(
                    description: R.string.localizable.failedToSyncError() + ": " + errorMessage
                )
            }
        }
        .ifOS(.iOS) {
            $0.refreshable { await self.viewModel.fetchRemoteForecasts() }
        }
        .navigationTitle(R.string.localizable.fourDayForecast())
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

enum OperatingSystem {
    case macOS
    case iOS
    case tvOS
    case watchOS

    #if os(macOS)
    static let current = macOS
    #elseif os(iOS)
    static let current = iOS
    #elseif os(tvOS)
    static let current = tvOS
    #elseif os(watchOS)
    static let current = watchOS
    #else
    #error("Unsupported platform")
    #endif
}

extension View {
    /**
    Conditionally apply modifiers depending on the target operating system.

    ```
    struct ContentView: View {
        var body: some View {
            Text("Unicorn")
                .font(.system(size: 10))
                .ifOS(.macOS, .tvOS) {
                    $0.font(.system(size: 20))
                }
        }
    }
    ```
    */
    @ViewBuilder
    func ifOS<Content: View>(
        _ operatingSystems: OperatingSystem...,
        modifier: (Self) -> Content
    ) -> some View {
        if operatingSystems.contains(OperatingSystem.current) {
            modifier(self)
        }
        else {
            self
        }
    }
}
