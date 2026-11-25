//
//  DayPartContentView.swift
//  EstonianWeather
//

import UIKit
import WeatherCore

enum DayPartKind {
    case night
    case day

    var title: String {
        switch self {
        case .night: String(localized: "Night")
        case .day: String(localized: "Day")
        }
    }
}

/// The night or day part of a forecast: title, temperature range, icon, description and places.
struct DayPartContentConfiguration: UIContentConfiguration {
    let kind: DayPartKind
    let dayPart: DayPartConfiguration

    func makeContentView() -> any UIView & UIContentView {
        DayPartContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> DayPartContentConfiguration {
        self
    }
}

final class DayPartContentView: UIView, UIContentView {
    var configuration: any UIContentConfiguration {
        didSet {
            self.apply()
        }
    }

    private let titleLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let iconView = UIImageView()
    private let titleRow = UIStackView()
    private let headerStack = UIStackView()
    private let descriptionLabel = UILabel()
    private let separator = UIView()
    private let placesStack = UIStackView()
    private lazy var separatorHeight = self.separator.heightAnchor.constraint(equalToConstant: 0.5)

    init(configuration: DayPartContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        self.setUpViews()
        self.apply()

        self.registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (view: Self, _) in
            view.updateHeaderLayout()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpViews() {
        self.titleLabel.font = .scaled(textStyle: .title2, weight: .semibold)
        self.titleLabel.adjustsFontForContentSizeCategory = true
        self.titleLabel.numberOfLines = 0

        self.temperatureLabel.font = .scaled(textStyle: .title2, weight: .medium, monospacedDigits: true)
        self.temperatureLabel.adjustsFontForContentSizeCategory = true
        self.temperatureLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.temperatureLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.iconView.contentMode = .scaleAspectFit
        self.iconView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        self.iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
            .applying(UIImage.SymbolConfiguration.preferringMulticolor())
        self.iconView.isAccessibilityElement = true
        self.iconView.accessibilityTraits = .image
        self.iconView.setContentHuggingPriority(.required, for: .horizontal)
        self.iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // The title takes the free width, which pushes the temperature and the icon to the trailing edge.
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleRow.axis = .horizontal
        self.titleRow.alignment = .center
        self.titleRow.spacing = 12
        self.titleRow.addArrangedSubview(self.titleLabel)
        self.titleRow.addArrangedSubview(self.iconView)

        self.headerStack.axis = .vertical
        self.headerStack.spacing = 8
        self.headerStack.addArrangedSubview(self.titleRow)

        self.descriptionLabel.font = .preferredFont(forTextStyle: .body)
        self.descriptionLabel.adjustsFontForContentSizeCategory = true
        self.descriptionLabel.numberOfLines = 0

        self.separator.backgroundColor = .separator
        self.separatorHeight.isActive = true

        self.placesStack.axis = .vertical
        self.placesStack.spacing = 8

        let rootStack = UIStackView(arrangedSubviews: [
            self.headerStack,
            self.descriptionLabel,
            self.separator,
            self.placesStack,
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(rootStack)

        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            rootStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            rootStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
        ])
    }

    // MARK: - Content

    private func apply() {
        guard let configuration = self.configuration as? DayPartContentConfiguration else {
            return
        }

        let dayPart = configuration.dayPart

        self.titleLabel.text = configuration.kind.title
        self.temperatureLabel.text = ForecastFormatter.temperatureRangeText(for: dayPart.temperatureRange)
        self.iconView.image = UIImage(systemName: WeatherPhenomenonIcon.symbolName(for: dayPart.phenomenon))
        self.iconView.accessibilityLabel = ForecastFormatter.phenomenonText(for: dayPart.phenomenon)
        self.descriptionLabel.text = dayPart.description

        for view in self.placesStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        for place in dayPart.places {
            self.placesStack.addArrangedSubview(PlaceRowView(place: place))
        }
        self.separator.isHidden = dayPart.places.isEmpty
        self.placesStack.isHidden = dayPart.places.isEmpty

        self.updateHeaderLayout()
    }

    /// At accessibility sizes the temperature moves under the title and icon instead of wrapping beside them.
    private func updateHeaderLayout() {
        let displayScale = self.traitCollection.displayScale
        self.separatorHeight.constant = displayScale > 0 ? 1 / displayScale : 0.5

        self.temperatureLabel.removeFromSuperview()

        if self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            self.headerStack.addArrangedSubview(self.temperatureLabel)
        }
        else {
            self.titleRow.insertArrangedSubview(self.temperatureLabel, at: 1)
        }
    }
}
