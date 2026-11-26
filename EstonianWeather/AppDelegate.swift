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

    /// Scene delegate adopted for the session restored from the SwiftUI build. `UIScene.delegate` is weak.
    private var adoptedSceneDelegate: SceneDelegate?

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

    /// The SwiftUI build persisted its scene sessions with its own delegate class (`SwiftUI.AppSceneDelegate`).
    /// UIKit restores such sessions with that delegate instead of the scene configuration in `Info.plist`
    /// (and iPhone cannot destroy them), so no `SceneDelegate` is attached and the window stays black.
    /// Attach one by hand.
    @objc private func sceneWillConnect(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene,
              Self.shouldAdoptScene(delegate: windowScene.delegate, role: windowScene.session.role)
        else {
            return
        }

        let sceneDelegate = SceneDelegate()
        self.adoptedSceneDelegate = sceneDelegate
        windowScene.delegate = sceneDelegate
        sceneDelegate.installWindow(in: windowScene)
    }

    /// Only app window scenes are adopted. On Mac, UIKit also connects its own menu bar scene without a delegate;
    /// adopting it built a second, hidden Forecasts screen that requested the forecast again (EES-95).
    static func shouldAdoptScene(delegate: (any UISceneDelegate)?, role: UISceneSession.Role) -> Bool {
        role == .windowApplication && !(delegate is SceneDelegate)
    }

    @objc private func sceneDidDisconnect(_ notification: Notification) {
        guard let scene = notification.object as? UIScene,
              let adoptedSceneDelegate,
              scene.delegate === adoptedSceneDelegate
        else {
            return
        }

        self.adoptedSceneDelegate = nil
    }
}
