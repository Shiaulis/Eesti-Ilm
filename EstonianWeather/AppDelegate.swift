//
//  AppDelegate.swift
//  EstonianWeather
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Shared by all scenes so the launch count is recorded once per process, not once per window.
    let ratingService = UserRatingService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SettingsConfiguration.publishVersionToSettingsBundle()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.sceneClass = UIWindowScene.self
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
