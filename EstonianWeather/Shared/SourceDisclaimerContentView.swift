//
//  SourceDisclaimerContentView.swift
//  EstonianWeather
//

import UIKit

/// The data-source disclaimer with a link to ilmateenistus.ee, for use in a list cell.
struct SourceDisclaimerContentConfiguration: UIContentConfiguration {
    let url: URL
    let urlDescription: String

    func makeContentView() -> any UIView & UIContentView {
        SourceDisclaimerContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> SourceDisclaimerContentConfiguration {
        self
    }
}

final class SourceDisclaimerContentView: UIView, UIContentView {
    var configuration: any UIContentConfiguration {
        didSet {
            self.apply()
        }
    }

    private let disclaimerLabel = UILabel()
    private let linkButton = UIButton(type: .system)

    init(configuration: SourceDisclaimerContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        self.disclaimerLabel.font = .preferredFont(forTextStyle: .caption1)
        self.disclaimerLabel.adjustsFontForContentSizeCategory = true
        self.disclaimerLabel.textColor = .secondaryLabel
        self.disclaimerLabel.textAlignment = .center
        self.disclaimerLabel.numberOfLines = 0
        self.disclaimerLabel.text = String(localized: .sourceDisclaimer)

        let stack = UIStackView(arrangedSubviews: [self.disclaimerLabel, self.linkButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)

        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
        ])

        self.apply()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply() {
        guard let configuration = self.configuration as? SourceDisclaimerContentConfiguration else {
            return
        }

        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.title = configuration.urlDescription
        buttonConfiguration.contentInsets = .zero
        buttonConfiguration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = UIFont.preferredFont(forTextStyle: .caption1)
            return attributes
        }
        self.linkButton.configuration = buttonConfiguration
        self.linkButton.addAction(
            UIAction { _ in
                UIApplication.shared.open(configuration.url)
            },
            for: .primaryActionTriggered
        )
        self.linkButton.accessibilityTraits.insert(.link)
    }
}
