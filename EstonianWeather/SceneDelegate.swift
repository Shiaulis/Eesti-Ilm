//
//  SceneDelegate.swift
//  EstonianWeather
//

import StoreKit
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var ratingPromptTask: Task<Void, Never>?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene,
              let ratingService = (UIApplication.shared.delegate as? AppDelegate)?.ratingService
        else {
            return
        }

        self.ratingPromptTask?.cancel()
        self.ratingPromptTask = Task {
            await ratingService.handleAppLaunch(
                delay: UserRatingService.defaultPromptDelay,
                requestReview: {
                    AppStore.requestReview(in: windowScene)
                }
            )
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        self.ratingPromptTask?.cancel()
        self.ratingPromptTask = nil
    }
}
