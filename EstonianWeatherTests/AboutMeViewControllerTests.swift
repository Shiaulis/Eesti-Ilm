//
//  AboutMeViewControllerTests.swift
//  EstonianWeatherTests
//

@testable import EstonianWeather
import Foundation
import Testing
import UIKit

@MainActor
struct AboutMeViewControllerTests {
    @Test func configuresNavigationTitleAndDisplayMode() {
        let controller = AboutMeViewController()
        controller.loadViewIfNeeded()

        #expect(controller.title == String(localized: "About me"))
        #expect(controller.navigationItem.largeTitleDisplayMode == .never)
    }

    @Test func configuresAccessibleBodyLabelAndHiddenPhoto() throws {
        let controller = AboutMeViewController()
        controller.loadViewIfNeeded()

        let imageViews = self.subviews(ofType: UIImageView.self, in: controller.view)
        let photoImageView = try #require(imageViews.first)
        let shadowContainer = try #require(photoImageView.superview)
        #expect(shadowContainer.accessibilityElementsHidden)
        #expect(!photoImageView.isAccessibilityElement)

        let labels = self.subviews(ofType: UILabel.self, in: controller.view)
            .filter { $0.text == String(localized: .aboutMeDescription) }
        let descriptionLabel = try #require(labels.first)
        #expect(descriptionLabel.numberOfLines == 0)
        #expect(descriptionLabel.adjustsFontForContentSizeCategory)
        #expect(descriptionLabel.textAlignment == .natural)
        #expect(descriptionLabel.font == .preferredFont(forTextStyle: .body))
    }

    @Test func tappingContactButtonOpensInjectedContactURL() throws {
        let expectedURL = try #require(URL(string: "mailto:developer@example.com"))
        var openedURL: URL?

        let controller = AboutMeViewController(
            contactURL: expectedURL,
            openURL: { openedURL = $0 }
        )
        controller.loadViewIfNeeded()

        let button = try #require(self.subviews(ofType: UIButton.self, in: controller.view).first)
        #expect(button.configuration?.title == String(localized: "Contact me"))

        button.sendActions(for: .primaryActionTriggered)
        #expect(openedURL == expectedURL)
    }

    @Test func omitsContactButtonWhenContactURLIsNil() {
        let controller = AboutMeViewController(contactURL: nil)
        controller.loadViewIfNeeded()

        #expect(self.subviews(ofType: UIButton.self, in: controller.view).isEmpty)
    }

    private func subviews<T: UIView>(ofType type: T.Type, in root: UIView) -> [T] {
        var result = [T]()
        if let match = root as? T {
            result.append(match)
        }
        for child in root.subviews {
            result.append(contentsOf: self.subviews(ofType: type, in: child))
        }
        return result
    }
}
