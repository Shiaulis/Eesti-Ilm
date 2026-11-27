//
//  SettingsViewControllerTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import SafariServices
import Testing
import UIKit

@MainActor
struct SettingsViewControllerTests {
    @Test func configuresNavigationTitleAndLargeTitleDisplayMode() {
        let controller = SettingsViewController()

        #expect(controller.title == String(localized: "Settings"))
        #expect(controller.navigationItem.largeTitleDisplayMode == .always)
    }

    @Test func configuresExpectedCellsInEnglish() throws {
        let controller = SettingsViewController(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"]
        )
        let collectionView = try self.collectionView(in: controller)

        #expect(collectionView.numberOfSections == 4)
        #expect(collectionView.numberOfItems(inSection: 0) == 1)
        #expect(collectionView.numberOfItems(inSection: 1) == 1)
        #expect(collectionView.numberOfItems(inSection: 2) == 2)
        #expect(collectionView.numberOfItems(inSection: 3) == 1)

        let languageCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? UICollectionViewListCell
        )
        let languageConfiguration = try #require(languageCell.contentConfiguration as? UIListContentConfiguration)
        #expect(languageConfiguration.text == String(localized: "Current language"))
        #expect(languageConfiguration.secondaryText == "English")
        #expect(languageCell.accessibilityHint == String(localized: "Opens app settings to change the language"))
        #expect(languageCell.accessibilityTraits.contains(.button))

        let aboutMeCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? UICollectionViewListCell
        )
        let aboutMeConfiguration = try #require(aboutMeCell.contentConfiguration as? UIListContentConfiguration)
        #expect(aboutMeConfiguration.text == String(localized: "About me"))
        #expect(aboutMeCell.accessories.count == 1)

        let supportCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? UICollectionViewListCell
        )
        let supportConfiguration = try #require(supportCell.contentConfiguration as? UIListContentConfiguration)
        #expect(supportConfiguration.text == String(localized: "Support"))
        #expect(supportCell.accessories.count == 1)
        #expect(supportCell.accessibilityTraits.contains(.link))

        let privacyPolicyCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 1, section: 2)) as? UICollectionViewListCell
        )
        let privacyPolicyConfiguration = try #require(
            privacyPolicyCell.contentConfiguration as? UIListContentConfiguration
        )
        #expect(privacyPolicyConfiguration.text == String(localized: "Privacy Policy"))
        #expect(privacyPolicyCell.accessories.count == 1)
        #expect(privacyPolicyCell.accessibilityTraits.contains(.link))

        let disclaimerCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 3)) as? UICollectionViewListCell
        )
        let disclaimerConfiguration = try #require(
            disclaimerCell.contentConfiguration as? SourceDisclaimerContentConfiguration
        )
        #expect(disclaimerConfiguration.url.absoluteString == "https://www.ilmateenistus.ee/?lang=en")
        #expect(disclaimerConfiguration.urlDescription == SettingsConfiguration.sourceDisclaimerHost)
    }

    @Test func configuresExpectedCellsInEstonian() throws {
        let controller = SettingsViewController(
            locale: Locale(identifier: "et_EE"),
            preferredLocalizations: ["et"]
        )
        let collectionView = try self.collectionView(in: controller)

        let languageCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? UICollectionViewListCell
        )
        let languageConfiguration = try #require(languageCell.contentConfiguration as? UIListContentConfiguration)
        #expect(languageConfiguration.secondaryText == "eesti")

        let disclaimerCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 3)) as? UICollectionViewListCell
        )
        let disclaimerConfiguration = try #require(
            disclaimerCell.contentConfiguration as? SourceDisclaimerContentConfiguration
        )
        #expect(disclaimerConfiguration.url.absoluteString == "https://www.ilmateenistus.ee/?lang=et")
    }

    @Test func disclaimerRowIsNotHighlightableOrSelectable() throws {
        let controller = SettingsViewController()
        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)

        let languageIndexPath = IndexPath(item: 0, section: 0)
        let aboutMeIndexPath = IndexPath(item: 0, section: 1)
        let supportIndexPath = IndexPath(item: 0, section: 2)
        let privacyPolicyIndexPath = IndexPath(item: 1, section: 2)
        let disclaimerIndexPath = IndexPath(item: 0, section: 3)

        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: languageIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: languageIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: aboutMeIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: aboutMeIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: supportIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: supportIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: privacyPolicyIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: privacyPolicyIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: disclaimerIndexPath) == false)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: disclaimerIndexPath) == false)
    }

    @Test func selectingLanguageCellOpensAppSettingsAndDeselects() throws {
        var openedURL: URL?
        let controller = SettingsViewController(openURL: { openedURL = $0 })
        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)
        let languageIndexPath = IndexPath(item: 0, section: 0)

        collectionView.selectItem(at: languageIndexPath, animated: false, scrollPosition: [])
        delegate.collectionView?(collectionView, didSelectItemAt: languageIndexPath)

        #expect(openedURL == SettingsConfiguration.appSettingsURL)
        #expect(collectionView.indexPathsForSelectedItems?.isEmpty == true)
    }

    @Test func selectingAboutMeCellPushesAboutMeViewControllerAndDeselects() throws {
        let controller = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)
        let aboutMeIndexPath = IndexPath(item: 0, section: 1)

        collectionView.selectItem(at: aboutMeIndexPath, animated: false, scrollPosition: [])
        delegate.collectionView?(collectionView, didSelectItemAt: aboutMeIndexPath)

        #expect(navigationController.viewControllers.count == 2)
        #expect(navigationController.topViewController is AboutMeViewController)
        #expect(collectionView.indexPathsForSelectedItems?.isEmpty == true)
    }

    @Test func selectingSupportAndPrivacyPolicyCellsPresentEnglishURLsAndDeselect() throws {
        var openedExternalURL: URL?
        var presentedURLs = [URL]()
        let controller = SettingsViewController(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"],
            openURL: { openedExternalURL = $0 },
            presentWebPage: { presentedURLs.append($0) }
        )
        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)

        let supportIndexPath = IndexPath(item: 0, section: 2)
        collectionView.selectItem(at: supportIndexPath, animated: false, scrollPosition: [])
        delegate.collectionView?(collectionView, didSelectItemAt: supportIndexPath)
        #expect(collectionView.indexPathsForSelectedItems?.isEmpty == true)

        let privacyPolicyIndexPath = IndexPath(item: 1, section: 2)
        collectionView.selectItem(at: privacyPolicyIndexPath, animated: false, scrollPosition: [])
        delegate.collectionView?(collectionView, didSelectItemAt: privacyPolicyIndexPath)
        #expect(collectionView.indexPathsForSelectedItems?.isEmpty == true)

        #expect(openedExternalURL == nil)
        #expect(
            presentedURLs.map(\.absoluteString) == [
                "https://eestiilm.app/support/",
                "https://eestiilm.app/privacy/",
            ]
        )
    }

    @Test func selectingSupportAndPrivacyPolicyCellsPresentEstonianURLs() throws {
        var presentedURLs = [URL]()
        let controller = SettingsViewController(
            locale: Locale(identifier: "et_EE"),
            preferredLocalizations: ["et"],
            presentWebPage: { presentedURLs.append($0) }
        )
        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)

        delegate.collectionView?(collectionView, didSelectItemAt: IndexPath(item: 0, section: 2))
        delegate.collectionView?(collectionView, didSelectItemAt: IndexPath(item: 1, section: 2))

        #expect(
            presentedURLs.map(\.absoluteString) == [
                "https://eestiilm.app/et/support/",
                "https://eestiilm.app/et/privacy/",
            ]
        )
    }

    @Test func selectingSupportCellPresentsSafariSheetByDefault() throws {
        let controller = SettingsViewController(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"]
        )
        let windowScene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        )
        let window = UIWindow(windowScene: windowScene)
        window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            controller.dismiss(animated: false)
            window.isHidden = true
            window.rootViewController = nil
        }

        let collectionView = try self.collectionView(in: controller)
        let delegate = try #require(collectionView.delegate)
        delegate.collectionView?(collectionView, didSelectItemAt: IndexPath(item: 0, section: 2))

        let presented = try #require(controller.presentedViewController as? SFSafariViewController)
        #expect(presented.modalPresentationStyle == .pageSheet)
    }

    private func collectionView(in controller: SettingsViewController) throws -> UICollectionView {
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        controller.view.layoutIfNeeded()

        let collectionView = try #require(
            controller.view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView
        )
        collectionView.layoutIfNeeded()
        return collectionView
    }
}
