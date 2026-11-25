//
//  RootTabBarController.swift
//  EstonianWeather
//

import UIKit

/// Root of the app: a tab bar on iPhone and a sidebar on iPad.
final class RootTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)

        self.mode = .tabSidebar
        self.tabs = AppTab.allCases.map { tab in
            UITab(
                title: String(localized: tab.titleResource),
                image: UIImage(systemName: tab.systemImageName),
                identifier: tab.rawValue
            ) { _ in
                Self.makeNavigationController(for: tab)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeNavigationController(for tab: AppTab) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: TemporaryHosting.rootViewController(for: tab))
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}
