//
//  SceneDelegate.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    // Assume supporting several scenes require us to have several root view models in future 🤔
    private var rootViewModel: RootViewModel!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Application lifecycle is pointless without scene")
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        guard let rootService = (UIApplication.shared.delegate as? AppDelegate)?.rootService else {
            fatalError("Application lifecycle is pointless without root service")
        }

        self.rootViewModel = .init(rootService: rootService)

        window.rootViewController = RootViewController(viewModel: self.rootViewModel)
        window.makeKeyAndVisible()
    }
}
