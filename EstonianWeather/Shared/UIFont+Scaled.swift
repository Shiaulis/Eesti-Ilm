//
//  UIFont+Scaled.swift
//  EstonianWeather
//

import UIKit

extension UIFont {
    /// A system font with the text style's default size that scales with Dynamic Type,
    /// optionally with a custom weight and fixed-width digits.
    static func scaled(
        textStyle: UIFont.TextStyle,
        weight: UIFont.Weight = .regular,
        monospacedDigits: Bool = false
    ) -> UIFont {
        let defaultTraits = UITraitCollection(preferredContentSizeCategory: .large)
        let baseSize = UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: defaultTraits).pointSize
        let font = monospacedDigits
            ? UIFont.monospacedDigitSystemFont(ofSize: baseSize, weight: weight)
            : UIFont.systemFont(ofSize: baseSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
