//
//  SettingsSnapshot.swift
//  EstonianWeather
//

import UIKit

nonisolated enum SettingsSection: Hashable, Sendable {
    case language
    case aboutMe
    case support
    case disclaimer
}

nonisolated enum SettingsItem: Hashable, Sendable {
    case currentLanguage
    case aboutMe
    case support
    case privacyPolicy
    case disclaimer
}

nonisolated enum SettingsSnapshot {
    /// Sections in display order: current language, About me, Support & Privacy Policy, and the data-source disclaimer when available.
    static func make(includesDisclaimer: Bool) -> NSDiffableDataSourceSnapshot<SettingsSection, SettingsItem> {
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingsItem>()
        snapshot.appendSections([.language, .aboutMe, .support])
        snapshot.appendItems([.currentLanguage], toSection: .language)
        snapshot.appendItems([.aboutMe], toSection: .aboutMe)
        snapshot.appendItems([.support, .privacyPolicy], toSection: .support)

        if includesDisclaimer {
            snapshot.appendSections([.disclaimer])
            snapshot.appendItems([.disclaimer], toSection: .disclaimer)
        }

        return snapshot
    }
}
