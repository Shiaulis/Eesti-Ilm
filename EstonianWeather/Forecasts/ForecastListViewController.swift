//
//  ForecastListViewController.swift
//  EstonianWeather
//

import UIKit
import WeatherCore

final class ForecastListViewController: UIViewController {
    private let viewModel: ForecastListViewModel
    private let disclaimerURL: URL?
    private var forecastsByID = [UUID: ForecastConfiguration]()
    private var appActivationObserver: (any NSObjectProtocol)?

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.makeLayout())
    private lazy var dataSource = self.makeDataSource()
    private lazy var contentUnavailableView = UIContentUnavailableView(configuration: .empty())

    init(
        viewModel: ForecastListViewModel = ForecastListViewModel(),
        preferredLocalizations: [String] = Bundle.main.preferredLocalizations
    ) {
        self.viewModel = viewModel
        self.disclaimerURL = SettingsConfiguration.sourceDisclaimerURL(
            locale: .autoupdatingCurrent,
            preferredLocalizations: preferredLocalizations
        )
        super.init(nibName: nil, bundle: nil)

        self.title = String(localized: "Forecasts")
        self.navigationItem.largeTitleDisplayMode = .always
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    isolated deinit {
        if let appActivationObserver {
            NotificationCenter.default.removeObserver(appActivationObserver)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = .systemGroupedBackground
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.allowsSelection = false
        self.collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction { [weak self] _ in
                Task {
                    await self?.refresh()
                }
            }
        )
        self.collectionView.frame = self.view.bounds
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.collectionView)

        // Replaces the SwiftUI `.task(id: scenePhase)`: refresh when the app becomes active on a later day.
        self.appActivationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.appDidBecomeActive()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Also covers a day change while this tab was not on screen when the scene activated.
        Task { [weak self] in
            await self?.viewModel.loadIfNeeded()
            await self?.viewModel.refreshIfStale()
        }
    }

    /// UIKit tracks the `@Observable` properties read here and calls this method again when they change.
    override func updateProperties() {
        super.updateProperties()

        switch self.viewModel.state {
        case .loading:
            self.show(forecasts: [])
            self.showContentUnavailable(self.loadingConfiguration())
        case let .loaded(forecasts):
            self.show(forecasts: forecasts)
            self.showContentUnavailable(nil)
        case let .failed(message):
            self.show(forecasts: [])
            self.showContentUnavailable(self.errorConfiguration(message: message))
        }
    }

    // MARK: - State

    private func appDidBecomeActive() {
        Task {
            await self.viewModel.refreshIfStale()
        }
    }

    private func refresh() async {
        await self.viewModel.refresh()
        self.collectionView.refreshControl?.endRefreshing()
    }

    private func show(forecasts: [ForecastConfiguration]) {
        self.forecastsByID = Dictionary(forecasts.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        // The disclaimer accompanies the forecasts only, as in the loading and error states there is no list.
        let snapshot = ForecastListSnapshot.make(
            forecasts: forecasts,
            includesDisclaimer: !forecasts.isEmpty && self.disclaimerURL != nil
        )
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Reuses one background view. Attaching a new view on every pass made UIKit re-run `updateProperties()`
    /// in a loop on Mac, and after detecting the loop UIKit stopped updating the screen (EES-94).
    private func showContentUnavailable(_ configuration: UIContentUnavailableConfiguration?) {
        guard let configuration else {
            self.collectionView.backgroundView = nil
            return
        }

        self.contentUnavailableView.configuration = configuration
        if self.collectionView.backgroundView !== self.contentUnavailableView {
            self.collectionView.backgroundView = self.contentUnavailableView
        }
    }

    private func loadingConfiguration() -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.loading()
        configuration.text = String(localized: "Loading")
        configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
        return configuration
    }

    private func errorConfiguration(message: String) -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = String(localized: "Error: \(message)")
        configuration.textProperties.font = .preferredFont(forTextStyle: .headline)

        var button = UIButton.Configuration.borderedProminent()
        button.title = String(localized: "Retry")
        configuration.button = button
        configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
            Task {
                await self?.refresh()
            }
        }
        return configuration
    }

    // MARK: - Layout and data source

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let section = self?.dataSource.sectionIdentifier(for: sectionIndex)
            configuration.headerMode = section == .disclaimer ? .none : .supplementary
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<ForecastListSection, ForecastListItem> {
        let dayPartRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ForecastListItem> { [weak self] cell, _, item in
            cell.contentConfiguration = self?.dayPartConfiguration(for: item)
        }
        let disclaimerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ForecastListItem> { [weak self] cell, _, _ in
            cell.contentConfiguration = self?.disclaimerURL.map {
                SourceDisclaimerContentConfiguration(url: $0, urlDescription: SettingsConfiguration.sourceDisclaimerHost)
            }
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, indexPath in
            var configuration = UIListContentConfiguration.header()
            if case let .forecast(id)? = self?.dataSource.sectionIdentifier(for: indexPath.section),
               let forecast = self?.forecastsByID[id]
            {
                configuration.text = ForecastFormatter.sectionTitle(for: forecast.date, locale: .autoupdatingCurrent)
            }
            configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
            configuration.textProperties.transform = .none
            configuration.textProperties.numberOfLines = 0
            header.contentConfiguration = configuration
        }

        let dataSource = UICollectionViewDiffableDataSource<ForecastListSection, ForecastListItem>(
            collectionView: self.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .night, .day:
                collectionView.dequeueConfiguredReusableCell(using: dayPartRegistration, for: indexPath, item: item)
            case .disclaimer:
                collectionView.dequeueConfiguredReusableCell(using: disclaimerRegistration, for: indexPath, item: item)
            }
        }
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return dataSource
    }

    private func dayPartConfiguration(for item: ForecastListItem) -> DayPartContentConfiguration? {
        switch item {
        case let .night(id):
            self.forecastsByID[id].map { DayPartContentConfiguration(kind: .night, dayPart: $0.night) }
        case let .day(id):
            self.forecastsByID[id].map { DayPartContentConfiguration(kind: .day, dayPart: $0.day) }
        case .disclaimer:
            nil
        }
    }
}

#Preview("Loaded") {
    let viewModel = ForecastListViewModel(
        fetchForecasts: { _ in
            [
                ForecastConfiguration(
                    date: .now,
                    night: DayPartConfiguration(
                        phenomenon: "Clear",
                        temperatureRange: TemperatureRange(minimum: 4, maximum: 9),
                        description: "Clear and calm night.",
                        places: [
                            PlaceConfiguration(name: "Tallinn", phenomenon: "Clear", temperature: .minimum(6)),
                        ]
                    ),
                    day: DayPartConfiguration(
                        phenomenon: "Few clouds",
                        temperatureRange: TemperatureRange(minimum: 14, maximum: 20),
                        description: "Mostly sunny with light southerly wind.",
                        places: [
                            PlaceConfiguration(name: "Tallinn", phenomenon: "Few clouds", temperature: .maximum(18)),
                        ]
                    )
                ),
            ]
        }
    )
    let navigationController = UINavigationController(rootViewController: ForecastListViewController(viewModel: viewModel))
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
