//
//  PlaceRowView.swift
//  EstonianWeather
//

import UIKit
import WeatherCore

/// A place with its weather icon and temperature.
/// The icon and the temperature never overlap: both keep their intrinsic width and only the name wraps.
final class PlaceRowView: UIView {
    private static let iconColumnWidth = 22.0
    private static let temperatureMinimumWidth = 44.0

    private let nameLabel = UILabel()
    private let iconView = UIImageView()
    private let temperatureLabel = UILabel()
    private let iconMinimumWidth: NSLayoutConstraint
    private let iconMaximumWidth: NSLayoutConstraint

    init(place: PlaceConfiguration) {
        self.iconMinimumWidth = self.iconView.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.iconColumnWidth)
        self.iconMaximumWidth = self.iconView.widthAnchor.constraint(lessThanOrEqualToConstant: Self.iconColumnWidth)
        super.init(frame: .zero)

        self.nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        self.nameLabel.adjustsFontForContentSizeCategory = true
        self.nameLabel.numberOfLines = 0
        self.nameLabel.text = place.name

        self.iconView.contentMode = .scaleAspectFit
        self.iconView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        self.iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
            .applying(UIImage.SymbolConfiguration.preferringMulticolor())
        self.iconView.image = UIImage(systemName: WeatherPhenomenonIcon.symbolName(for: place.phenomenon))
        self.iconView.isAccessibilityElement = true
        self.iconView.accessibilityTraits = .image
        self.iconView.accessibilityLabel = ForecastFormatter.phenomenonText(for: place.phenomenon)
        // Only the name wraps. Hugging stays just below required so the icon column cap can still win.
        self.iconView.setContentHuggingPriority(UILayoutPriority.required - 1, for: .horizontal)
        self.iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.temperatureLabel.font = .scaled(textStyle: .subheadline, monospacedDigits: true)
        self.temperatureLabel.adjustsFontForContentSizeCategory = true
        self.temperatureLabel.textColor = .secondaryLabel
        self.temperatureLabel.textAlignment = .right
        self.temperatureLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.temperatureLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        var arrangedSubviews = [self.nameLabel, self.iconView]
        if let temperatureText = ForecastFormatter.placeTemperatureText(for: place.temperature) {
            self.temperatureLabel.text = temperatureText
            arrangedSubviews.append(self.temperatureLabel)
            self.temperatureLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.temperatureMinimumWidth).isActive = true
        }

        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.iconMinimumWidth,
        ])

        self.updateIconColumn()
        self.registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (view: Self, _) in
            view.updateIconColumn()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The icon column has a fixed width so that icons line up, except at accessibility sizes
    /// where the icon may grow beyond it instead of being clipped.
    private func updateIconColumn() {
        let width = UIFontMetrics(forTextStyle: .body).scaledValue(for: Self.iconColumnWidth, compatibleWith: self.traitCollection)
        self.iconMinimumWidth.constant = width
        self.iconMaximumWidth.constant = width
        self.iconMaximumWidth.isActive = !self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    }
}
