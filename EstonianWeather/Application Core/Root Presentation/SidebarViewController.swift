//
//  SidebarViewController.swift
//  EstonianWeather
//
//  Created by Andrius Siaulis on 10.07.2021.
//

import Combine
import UIKit

protocol SidebarViewModel {
    var selectedTabPublisher: AnyPublisher<TabItem, Never> { get }

    func select(_ tab: TabItem)
}

final class SidebarViewController: UICollectionViewController, UISplitViewControllerDelegate {
    private typealias DataSource = UICollectionViewDiffableDataSource<SidebarSection, TabItem>
    private enum SidebarSection: Int { case main }

    // MARK: - Properties

    private let viewModel: SidebarViewModel
    private var dataSource: DataSource!
    private var disposables: Set<AnyCancellable> = []

    // MARK: - Init

    init(viewModel: SidebarViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.createLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        applyInitialSnapshot()
        self.title = "Eesti Ilm"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.clearsSelectionOnViewWillAppear = false

        self.viewModel
            .selectedTabPublisher
            .sink { [weak self] selectedTab in
                guard let self else { return }

                let selectedIndexPath = selectedTab.indexPath
                let currentSelection = self.collectionView.indexPathsForSelectedItems ?? []
                // We need to prevent from selection of already selected row
                guard !currentSelection.contains(selectedIndexPath) else { return }

                self.collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .init(rawValue: 0))
            }
            .store(in: &self.disposables)
    }

    // MARK: - Delegate methods -

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTab = self.dataSource.itemIdentifier(for: indexPath) else { return }

        self.viewModel.select(selectedTab)
    }

    // MARK: - Private methods

    private func configureDataSource() {
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TabItem> { cell, _, tab in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = tab.title
            contentConfiguration.image = UIImage(systemName: tab.imageName)
            cell.contentConfiguration = contentConfiguration
        }

        self.dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, tab -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: tab)
        }
    }

    private func applyInitialSnapshot() {
        self.dataSource.apply(snapshot(), to: .main, animatingDifferences: false)
    }

    private func snapshot() -> NSDiffableDataSourceSectionSnapshot<TabItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<TabItem>()
        let items: [TabItem] = TabItem.allCases

        snapshot.append(items)
        return snapshot
    }

    // MARK: - Private static methods

    private static func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
}
