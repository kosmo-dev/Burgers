//
//  HomeViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit
//import FirebaseStorage

class HomeViewController: UIViewController, OrderControlling, CacheControlling {

    let toMenuItemSegue = "toMenuItemSegue"
    let toNewsItemSegue = "toNewsItemSegue"

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section {
        case news
        case menu
    }

    var requestTask: Task<Void, Never>? = nil

    var menuItems: [Item] = []
    var newsItems: [Item] = []
    var menuHeaders = ["BURGERS", "BOWLS", "SNACKS", "SALADS", "STEAKS", "DRINKS"]
    
    var sections: [Section] = []
    lazy var headerView = HeaderReusableView()

    lazy var dataSource = configureDataSource()

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem.image = UIImage(systemName: "menucard")
        tabBarItem.selectedImage = UIImage(systemName: "menucard.fill")
        tabBarItem.title = "Menu"
    }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self

        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier)

        update()
    }

    // MARK: Functions

    func update() {
        requestTask?.cancel()

        requestTask = Task {
            if let menuItemsDecoded = try? await MenuItemRequest().send() {
                for i in menuItemsDecoded {
                    menuItems.append(Item.menu(i.value))
                }
                self.menuItems = self.menuItems.sorted(by: {$0.menuItem.id < $1.menuItem.id})
            }

            if let newsItemsDecoded = try? await NewsItemRequest().send() {
                for i in newsItemsDecoded {
                    newsItems.append(Item.news(i))
                }
                self.newsItems = self.newsItems.sorted(by: {$0.newsItem.timestamp > $1.newsItem.timestamp})
            }
            applySnaphot()

            await fetchPhoto(from: newsItems)
        }

    }

    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .news:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsItemCollectionViewCell.reuseIdentifier, for: indexPath) as? NewsItemCollectionViewCell
                let image: UIImage? = self.cacheController.images[item.newsItem.id]
                cell?.configureCell(item.newsItem.name, image)
                return cell

            case .menu:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuItemCollectionViewCell.reuseIdentifier, for: indexPath) as? MenuItemCollectionViewCell
                let image: UIImage? = self.cacheController.images[item.menuItem.id]
                cell?.configureCell(menuItem: item.menuItem, image: image)
                cell?.delegate = self
                return cell
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as! HeaderReusableView
            headerView.setupView(self.menuHeaders)
            self.headerView = headerView
            return headerView
        }
        return dataSource
    }

    func applySnaphot() {
        var snapshot = Snapshot()

        snapshot.appendSections([.news, .menu])
        snapshot.appendItems(newsItems, toSection: .news)
        snapshot.appendItems(menuItems, toSection: .menu)

        sections = snapshot.sectionIdentifiers

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func updateSnaphot(with items: [Item]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func generateLayout() -> UICollectionViewLayout {

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

    func fetchPhoto(from itemsArray: [Item]) async {

        for item in itemsArray {
            var url: String {
                switch item {
                case .menu(let menu):
                    return menu.photoCompressedURL
                case .news(let news):
                    return news.photoURL
                }
            }

            if let image = try? await MenuItemImageRequest().send(url: url) {
                switch item {
                case .menu(_):
                    cacheController.addToImages(image, for: item.menuItem.id)
                case .news(_):
                    cacheController.addToImages(image, for: item.newsItem.id)
                }
                updateSnaphot(with: [item])
            }
        }
    }

    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: UICollectionViewCell?) -> MenuItemViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath)?.menuItem else {return nil}
        let image = cacheController.images[item.id]
        return MenuItemViewController(coder: coder, menuItem: item, image: image)
    }

    @IBSegueAction func showNewsItem(_ coder: NSCoder, sender: UICollectionViewCell?) -> NewsItemViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath)?.newsItem else {return nil}
        let image = cacheController.images[item.id]
        return NewsItemViewController(coder: coder, newsItem: item, image: image)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func getMenuItem(indexPath: IndexPath) -> Item {
        return menuItems[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

            if !cacheController.images.contains(where: { $0.key == menuItems[indexPath.row].menuItem.id }) {
            Task {
                await fetchPhoto(from: [getMenuItem(indexPath: indexPath)])
            }
        }
    }
}

extension HomeViewController: MenuItemCellDelegate {
    func chooseButtonWasTapped(cell: MenuItemCollectionViewCell) {
        if let menuItem = cell.menuItem {
            orderController.addToOrder(menuItem)
        }
    }
}
