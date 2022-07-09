//
//  AppDelegate.swift
//  test
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    let rootService: RootService = .init()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        .init(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
