//
//  AppDelegateTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Testing
import UIKit

@MainActor
struct AppDelegateTests {
    @Test func adoptsAppWindowSceneWithoutSceneDelegate() {
        #expect(AppDelegate.shouldAdoptScene(delegate: nil, role: .windowApplication))
    }

    @Test func skipsSceneThatAlreadyHasSceneDelegate() {
        #expect(!AppDelegate.shouldAdoptScene(delegate: SceneDelegate(), role: .windowApplication))
    }

    /// The Mac menu bar scene connects without a delegate and must not get a Forecasts screen (EES-95).
    @Test func skipsMacMenuBarScene() {
        let menuBarRole = UISceneSession.Role(rawValue: "FUWindowSceneSessionRoleSystemUI")

        #expect(!AppDelegate.shouldAdoptScene(delegate: nil, role: menuBarRole))
    }
}
