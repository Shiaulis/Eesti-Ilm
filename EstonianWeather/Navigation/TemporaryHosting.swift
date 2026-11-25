//
//  TemporaryHosting.swift
//  EstonianWeather
//

import SwiftUI

/// TEMPORARY: hosts the SwiftUI screens until they are rewritten in UIKit.
/// Remove the `.forecasts` case with EES-87 and the `.settings` case with EES-89, then delete this file.
/// The SwiftUI views set `.navigationTitle`, which `UIHostingController` forwards to the UIKit
/// navigation item, so they must not be wrapped in their own `NavigationStack`.
enum TemporaryHosting {
    static func rootViewController(for tab: AppTab) -> UIViewController {
        switch tab {
        case .forecasts:
            UIHostingController(rootView: ForecastListView())
        case .settings:
            UIHostingController(rootView: SettingsView())
        }
    }
}
