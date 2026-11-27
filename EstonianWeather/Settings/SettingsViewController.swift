//
//  SettingsViewController.swift
//  EstonianWeather
//

import SafariServices
import UIKit

final class SettingsViewController: UIViewController, UICollectionViewDelegate {
    private let locale: Locale
    private let preferredLocalizations: [String]
    private let openURL: ((URL) -> Void)?
    private let presentWebPage: ((URL) -> Void)?
    private let supportURL: URL?
    private let privacyPolicyURL: URL?
    private let disclaimerURL: URL?

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.makeLayout())
    private lazy var dataSource = self.makeDataSource()

    init(
        locale: Locale = .autoupdatingCurrent,
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations,
        openURL: ((URL) -> Void)? = nil,
        presentWebPage: ((URL) -> Void)? = nil
    ) {
        self.locale = locale
        self.preferredLocalizations = preferredLocalizations
        self.openURL = openURL
        self.presentWebPage = presentWebPage
        self.supportURL = SettingsConfiguration.supportURL(
            locale: locale,
            preferredLocalizations: preferredLocalizations
        )
        self.privacyPolicyURL = SettingsConfiguration.privacyPolicyURL(
            locale: locale,
            preferredLocalizations: preferredLocalizations
        )
        self.disclaimerURL = SettingsConfiguration.sourceDisclaimerURL(
            locale: locale,
            preferredLocalizations: preferredLocalizations
        )
        super.init(nibName: nil, bundle: nil)

        self.title = String(localized: "Settings")
        self.navigationItem.largeTitleDisplayMode = .always
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = .systemGroupedBackground
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.delegate = self
        self.collectionView.frame = self.view.bounds
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.collectionView)

        self.applySnapshot()
    }

    // MARK: - Layout and data source

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<SettingsSection, SettingsItem> {
        let languageRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingsItem> { [weak self] cell, _, _ in
            guard let self else {
                return
            }

            var configuration = UIListContentConfiguration.valueCell()
            configuration.text = String(localized: "Current language")
            configuration.secondaryText = SettingsConfiguration.currentLanguageDisplayName(
                locale: self.locale,
                preferredLocalizations: self.preferredLocalizations
            )
            cell.contentConfiguration = configuration
            cell.accessibilityHint = String(localized: "Opens app settings to change the language")
            cell.accessibilityTraits.insert(.button)
        }

        let aboutMeRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingsItem> { cell, _, _ in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = String(localized: "About me")
            cell.contentConfiguration = configuration
            cell.accessories = [.disclosureIndicator()]
        }

        let linkRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingsItem> { cell, _, item in
            var configuration = cell.defaultContentConfiguration()
            switch item {
            case .support:
                configuration.text = String(
                    localized: "Support",
                    comment: "Row label in Settings that opens the app support webpage."
                )
            case .privacyPolicy:
                configuration.text = String(
                    localized: "Privacy Policy",
                    comment: "Row label in Settings that opens the app privacy policy webpage."
                )
            case .currentLanguage, .aboutMe, .disclaimer:
                break
            }
            cell.contentConfiguration = configuration
            cell.accessories = [.disclosureIndicator()]
            cell.accessibilityTraits.insert(.link)
        }

        let disclaimerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingsItem> { [weak self] cell, _, _ in
            cell.contentConfiguration = self?.disclaimerURL.map {
                SourceDisclaimerContentConfiguration(
                    url: $0,
                    urlDescription: SettingsConfiguration.sourceDisclaimerHost
                )
            }
        }

        return UICollectionViewDiffableDataSource<SettingsSection, SettingsItem>(
            collectionView: self.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .currentLanguage:
                collectionView.dequeueConfiguredReusableCell(using: languageRegistration, for: indexPath, item: item)
            case .aboutMe:
                collectionView.dequeueConfiguredReusableCell(using: aboutMeRegistration, for: indexPath, item: item)
            case .support, .privacyPolicy:
                collectionView.dequeueConfiguredReusableCell(using: linkRegistration, for: indexPath, item: item)
            case .disclaimer:
                collectionView.dequeueConfiguredReusableCell(using: disclaimerRegistration, for: indexPath, item: item)
            }
        }
    }

    private func applySnapshot() {
        let snapshot = SettingsSnapshot.make(includesDisclaimer: self.disclaimerURL != nil)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        self.dataSource.itemIdentifier(for: indexPath) != .disclaimer
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.dataSource.itemIdentifier(for: indexPath) != .disclaimer
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        switch self.dataSource.itemIdentifier(for: indexPath) {
        case .currentLanguage:
            self.openAppSettings()
        case .aboutMe:
            self.showAboutMe()
        case .support:
            self.showWebPage(self.supportURL)
        case .privacyPolicy:
            self.showWebPage(self.privacyPolicyURL)
        case .disclaimer, nil:
            break
        }
    }

    // MARK: - Actions

    private func openAppSettings() {
        guard let settingsURL = SettingsConfiguration.appSettingsURL else {
            return
        }

        if let openURL = self.openURL {
            openURL(settingsURL)
        }
        else if let windowScene = self.view.window?.windowScene {
            windowScene.open(settingsURL, options: nil)
        }
        else {
            UIApplication.shared.open(settingsURL)
        }
    }

    private func showAboutMe() {
        self.navigationController?.pushViewController(AboutMeViewController(), animated: true)
    }

    private func showWebPage(_ url: URL?) {
        guard let url else {
            return
        }

        if let presentWebPage = self.presentWebPage {
            presentWebPage(url)
        }
        else if self.presentedViewController == nil {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .pageSheet
            self.present(safariViewController, animated: true)
        }
    }
}

#Preview("English") {
    let navigationController = UINavigationController(
        rootViewController: SettingsViewController(
            locale: Locale(identifier: "en_US"),
            preferredLocalizations: ["en"]
        )
    )
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}

#Preview("Estonian") {
    let navigationController = UINavigationController(
        rootViewController: SettingsViewController(
            locale: Locale(identifier: "et_EE"),
            preferredLocalizations: ["et"]
        )
    )
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
