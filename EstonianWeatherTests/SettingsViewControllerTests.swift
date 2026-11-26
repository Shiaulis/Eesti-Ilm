//
//  SettingsViewControllerTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
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

        #expect(collectionView.numberOfSections == 3)
        #expect(collectionView.numberOfItems(inSection: 0) == 1)
        #expect(collectionView.numberOfItems(inSection: 1) == 1)
        #expect(collectionView.numberOfItems(inSection: 2) == 1)

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

        let disclaimerCell = try #require(
            collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? UICollectionViewListCell
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
            collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? UICollectionViewListCell
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
        let disclaimerIndexPath = IndexPath(item: 0, section: 2)

        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: languageIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: languageIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldHighlightItemAt: aboutMeIndexPath) == true)
        #expect(delegate.collectionView?(collectionView, shouldSelectItemAt: aboutMeIndexPath) == true)
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
