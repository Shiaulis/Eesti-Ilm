//
//  AppDelegate.swift
//  EstonianWeather
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Owned by the app, not the scene, so the launch count is recorded once per process
    /// even when iOS disconnects the window scene in the background and connects it again.
    let ratingService = UserRatingService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SettingsConfiguration.publishVersionToSettingsBundle()
        return true
    }
}
