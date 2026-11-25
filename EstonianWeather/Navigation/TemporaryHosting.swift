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
            SettingsHostingController()
        }
    }
}

/// TEMPORARY (EES-89): pushes the About me screen onto the UIKit navigation stack
/// until Settings is rewritten in UIKit.
private final class SettingsHostingController: UIHostingController<SettingsView> {
    init() {
        super.init(rootView: SettingsView())
        self.rootView = SettingsView(showAboutMe: { [weak self] in
            self?.navigationController?.pushViewController(
                AboutMeViewController(),
                animated: true
            )
        })
    }

    @available(*, unavailable)
    dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
