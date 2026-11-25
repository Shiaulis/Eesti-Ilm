//
//  AppDelegate.swift
//  EstonianWeather
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Shared by all scenes so the launch count is recorded once per process, not once per window.
    let ratingService = UserRatingService()

    /// Scene delegates adopted for sessions restored from the SwiftUI build. `UIScene.delegate` is weak.
    private var adoptedSceneDelegates = [ObjectIdentifier: SceneDelegate]()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SettingsConfiguration.publishVersionToSettingsBundle()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.sceneWillConnect(_:)),
            name: UIScene.willConnectNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.sceneDidDisconnect(_:)),
            name: UIScene.didDisconnectNotification,
            object: nil
        )
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.sceneClass = UIWindowScene.self
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    /// The SwiftUI build persisted its scene sessions with its own delegate class (`SwiftUI.AppSceneDelegate`).
    /// UIKit restores such sessions without calling `application(_:configurationForConnecting:options:)`
    /// (and iPhone cannot destroy them), so no `SceneDelegate` is attached and the window stays black.
    /// Attach one by hand.
    @objc private func sceneWillConnect(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene,
              !(windowScene.delegate is SceneDelegate)
        else {
            return
        }

        let sceneDelegate = SceneDelegate()
        self.adoptedSceneDelegates[ObjectIdentifier(windowScene)] = sceneDelegate
        windowScene.delegate = sceneDelegate
        sceneDelegate.installWindow(in: windowScene)
    }

    @objc private func sceneDidDisconnect(_ notification: Notification) {
        guard let scene = notification.object as? UIScene else {
            return
        }

        self.adoptedSceneDelegates[ObjectIdentifier(scene)] = nil
    }
}
