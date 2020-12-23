//
//  ForecastListView.swift
//  EstonianWeather
//
//  Created by Andrius Shiaulis on 12.01.2020.
//  Copyright © 2020 Andrius Shiaulis. All rights reserved.
//

import SwiftUI

struct ForecastListView<ViewModel: ForecastListViewModel>: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ViewModel

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack {
                SyncStatusView(status: self.viewModel.syncStatus)
                ScrollView {
                    LazyVStack {
                        ForEach(self.viewModel.displayItems) { displayItem in
                            ForecastView(item: displayItem)
                        }
                    }
                    .padding()
                }
                .navigationTitle("4_days_forecast")
                .navigationBarColor(backgroundColor: Resource.Color.appRose, tintColor: .white)
            }
        }
    }

}

struct SyncStatusView: View {
    let status: SyncStatus

    private var color: Color {
        switch status {
        case .synced: return .white
        case .syncing: return .white
        case .failed: return .white
        case .ready: return .white
        }
    }

    private var description: String {
        switch status {
        case .synced(let syncDate):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            formatter.doesRelativeDateFormatting = true
            let prefix = "✅ \(NSLocalizedString("synced ", comment: ""))"
            return prefix + formatter.string(from: syncDate)
        case .syncing:
            return " 🔄 \(NSLocalizedString("syncing", comment: ""))"
        case .failed(let errorDescription):
            return NSLocalizedString("failed_to_sync_error", comment: "") + errorDescription
        case .ready:
            return NSLocalizedString("ready", comment: "")
        }
    }

    var body: some View {
        HStack {
            Spacer()
            Text(self.description)
                .foregroundColor(self.color)
                .font(.caption)
                .padding(.bottom, 4)
            Spacer()
        }
        .background(Color(Resource.Color.appRose))
    }
}

struct ForecastListView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastListView(viewModel: MockForecastListViewModel())
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
