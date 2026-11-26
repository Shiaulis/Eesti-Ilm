//
//  SceneDelegate.swift
//  EstonianWeather
//

import StoreKit
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let ratingService = UserRatingService()
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

        // Counts each time the app window opens, not each return to the foreground.
        self.ratingService.recordLaunch()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        self.ratingPromptTask?.cancel()
        self.ratingPromptTask = Task { [ratingService] in
            await ratingService.promptIfEligible {
                AppStore.requestReview(in: windowScene)
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        self.ratingPromptTask?.cancel()
        self.ratingPromptTask = nil
    }
}
