//
//  MainViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

final class MainViewController: UIViewController, OrderControlling, ImageControlling {

    // MARK: - IB Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Private Properties
    private let toMenuItemSegue = "toMenuItemSegue"
    private let toNewsItemSegue = "toNewsItemSegue"

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DataSourceItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DataSourceItem>

    private enum Section {
        case news
        case menu
    }

    private var menuItems: [DataSourceItem] = []
    private var menuHeaders: [String] = []

    private var sections: [Section] = []
    lazy private var dataSource = configureDataSource()

    lazy private var headerView = HeaderReusableView()
    lazy private var headerViewHeight: CGFloat = 0

    private var itemsFactory: ItemsFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?

    // MARK: - Initializers
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem.image = UIImage(systemName: "book")
        tabBarItem.selectedImage = UIImage(systemName: "book.fill")
        tabBarItem.title = "Menu"
    }

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier)

        itemsFactory = ItemsFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)

        getMenuAndNewsItems()
    }

    // MARK: - Private Methods
    private func getMenuAndNewsItems() {
        Task {
            await itemsFactory?.getMenuAndNewsItems()
        }
    }
    private func fetchPhoto(from itemsArray: [DataSourceItem]) async {
        for item in itemsArray {
            var url: String {
                switch item {
                case .menu(let menu):
                    return menu.photoCompressedURL
                case .news(let news):
                    return news.photoURL
                }
            }
            await imageController.fetchImage(url: url)
            updateSnaphot(with: [item])
        }
    }

    // MARK: - Segue Actions
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: UICollectionViewCell?) -> MenuItemViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath)?.menuItem else {return nil}
        let image = imageController.images[item.photoCompressedURL]
        return nil
//        return MenuItemViewController(coder: coder, menuItem: item, image: image)
    }

    @IBSegueAction func showNewsItem(_ coder: NSCoder, sender: UICollectionViewCell?) -> NewsItemViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath)?.newsItem else {return nil}
        let image = imageController.images[item.photoURL]
//        return NewsItemViewController(coder: coder, newsItem: item, image: image)
        return nil
    }
}

// MARK: - Configure Data Source
extension MainViewController {
    private func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .news:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsItemCollectionViewCell.reuseIdentifier, for: indexPath) as? NewsItemCollectionViewCell
                let image = self.imageController.images[item.newsItem.photoURL]
                cell?.configureCell(item.newsItem.name, image)
                return cell

            case .menu:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuItemCollectionViewCell.reuseIdentifier, for: indexPath) as? MenuItemCollectionViewCell
                let image = self.imageController.images[item.menuItem.photoCompressedURL]
                cell?.configureCell(menuItem: item.menuItem, image: image)
                cell?.delegate = self
                return cell
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as! HeaderReusableView
            headerView.setupView(self.menuHeaders)
            headerView.delegate = self
            self.headerViewHeight = headerView.bounds.height
            self.headerView = headerView
            return headerView
        }
        return dataSource
    }

    private func applySnaphot(_ menuItems: [DataSourceItem], _ newsItems: [DataSourceItem]) {
        var snapshot = Snapshot()

        snapshot.appendSections([.news, .menu])
        snapshot.appendItems(newsItems, toSection: .news)
        snapshot.appendItems(menuItems, toSection: .menu)

        sections = snapshot.sectionIdentifiers
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    private func updateSnaphot(with items: [DataSourceItem]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

// MARK: - ItemsFactoryDelegate
extension MainViewController: ItemsFactoryDelegate {
    func didReceivedItems(menuItems: [DataSourceItem], newsItems: [DataSourceItem], menuHeaders: [String]) {
        self.menuItems = menuItems
        self.menuHeaders = menuHeaders
        applySnaphot(menuItems, newsItems)
        Task {
            await fetchPhoto(from: newsItems)
        }
    }

    func failedReceiveMenuAndNewsItems() {
        showErrorAlert()
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    private func getMenuItem(indexPath: IndexPath) -> DataSourceItem {
        return menuItems[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !imageController.images.contains(where: {$0.key == menuItems[indexPath.row].menuItem.photoCompressedURL}) else {return}
        Task {
            await fetchPhoto(from: [getMenuItem(indexPath: indexPath)])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.minY + headerViewHeight)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else {return}
        headerView.scrollViewTo(header: menuItems[visibleIndexPath.row].menuItem.type, index: visibleIndexPath.row)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}

// MARK: - MenuItemCellDelegate
extension MainViewController: MenuItemCellDelegate {
    func chooseButtonWasTapped(cell: MenuItemCollectionViewCell) {
        guard let menuItem = cell.menuItem else {return}
        orderController.addToOrder(menuItem)
    }
}

// MARK: - HeaderReusableViewDelegate
extension MainViewController: HeaderReusableViewDelegate {
    func headerLabelWasTapped(_ header: String) {
        guard let index = menuItems.firstIndex(where: {$0.menuItem.type.uppercased() == header}) else {return}
        collectionView.scrollToItem(at: IndexPath(item: index, section: 1), at: .top, animated: true)
    }
}

// MARK: - Error handling
extension MainViewController {
    private func showErrorAlert() {
        let alertModel = AlertModel(
            title: "Server is not responding",
            message: "It seems you do not have internet connection or server is unavailable. Do you want to try again?",
            actionConfirmText: "Try again",
            actionCancelText: "Cancel",
            actionConfirmCompletion: { [weak self] in
                guard let self else {return}
                self.getMenuAndNewsItems()
            },
            actionCancelCompletion: {
            })
        alertPresenter?.show(alertModel: alertModel)
    }
}

// MARK: - AlertPresenterDelegate
extension MainViewController: AlertPresenterDelegate {
    func presentAlertView(alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - CompositionalLayout
extension MainViewController {
    private func generateLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            let section = self.sections[sectionIndex]

            switch section {
            case .news:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/2.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

                return section

            case .menu:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
                headerItem.pinToVisibleBounds = true
                headerItem.zIndex = 2

                section.boundarySupplementaryItems = [headerItem]

                return section
            }
        }
        return layout
    }
}
