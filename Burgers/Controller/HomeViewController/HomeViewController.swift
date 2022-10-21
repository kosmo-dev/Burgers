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

    var menuItems: [Item] = []
    var newsItems: [Item] = []
    var menuHeaders: [String] = []
    var sections: [Section] = []
    lazy var dataSource = configureDataSource()

    lazy var headerView = HeaderReusableView()
    lazy var headerViewHeight: CGFloat = 0

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: View Life Cycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem.image = UIImage(systemName: "book")
        tabBarItem.selectedImage = UIImage(systemName: "book.fill")
        tabBarItem.title = "Menu"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier)

        update()
    }

    // MARK: Functions
    func update() {
        Task {
            if let menuItemsDecoded = try? await MenuItemRequest().send() {
                for i in menuItemsDecoded {
                    menuItems.append(Item.menu(i.value))
                }
                self.menuItems = self.menuItems.sorted(by: {$0.menuItem.id < $1.menuItem.id})
                self.menuHeaders = menuItems.map {$0.menuItem.type.uppercased()}
                self.menuHeaders = menuHeaders.makeUniqueElements()
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

            guard let image = try? await MenuItemImageRequest().send(url: url) else {return}
            switch item {
            case .menu(_):
                cacheController.addToImages(image, for: item.menuItem.id)
            case .news(_):
                cacheController.addToImages(image, for: item.newsItem.id)
            }
            updateSnaphot(with: [item])
        }
    }

    // MARK: Segue Actions
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

// MARK: - Configure Data Source
extension HomeViewController {
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
            headerView.delegate = self
            self.headerViewHeight = headerView.bounds.height
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
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func getMenuItem(indexPath: IndexPath) -> Item {
        return menuItems[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !cacheController.images.contains(where: {$0.key == menuItems[indexPath.row].menuItem.id}) else {return}
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
extension HomeViewController: MenuItemCellDelegate {
    func chooseButtonWasTapped(cell: MenuItemCollectionViewCell) {
        guard let menuItem = cell.menuItem else {return}
        orderController.addToOrder(menuItem)
    }
}

// MARK: - HeaderReusableViewDelegate
extension HomeViewController: HeaderReusableViewDelegate {
    func headerLabelWasTapped(_ header: String) {
        guard let index = menuItems.firstIndex(where: {$0.menuItem.type.uppercased() == header}) else {return}
        collectionView.scrollToItem(at: IndexPath(item: index, section: 1), at: .top, animated: true)
    }
}
