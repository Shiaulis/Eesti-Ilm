//
//  AppDelegate.swift
//  test
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    let rootService = RootService()

    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Task {
            await self.rootService.start()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        .init(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
