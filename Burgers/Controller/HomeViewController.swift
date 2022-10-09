//
//  HomeViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit
//import FirebaseStorage

class HomeViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section {
        case news
        case menu
    }

    var requestTask: Task<Void, Never>? = nil

    var menuItems: [Item] = []
    var newsItems: [Item] = []
    var imageSource: [Int: UIImage] = [:]
    var menuHeaders = ["BURGERS", "SNACKS", "SALADS", "STEAKS", "DRINKS"]
    var sections: [Section] = []

    lazy var dataSource = configureDataSource()

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = generateLayout()
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier)

        update()
    }

    // MARK: Functions

    func update() {
        requestTask?.cancel()

        requestTask = Task {
            if let menuItemsDecoded = try? await MenuItemRequest().send() {
                var newDataSource = [Item]()
                for i in menuItemsDecoded {
                    newDataSource.append(Item.menu(i.value))
                }
                self.menuItems = newDataSource
                self.menuItems = self.menuItems.sorted(by: {$0.menuItem.id < $1.menuItem.id})
            } else {
                self.menuItems = []
            }

            if let newsItemsDecoded = try? await NewsItemRequest().send() {
                for i in newsItemsDecoded {
                    newsItems.append(Item.news(i))
                }
                self.newsItems = self.newsItems.sorted(by: {$0.newsItem.timestamp > $1.newsItem.timestamp})
            } else {
                self.newsItems = []
            }

            applySnaphot()

            for menuItem in menuItems {
                if let image = try? await MenuItemImageRequest().send(url: menuItem.menuItem.photoCompressedURL) {
                    imageSource[menuItem.menuItem.id] = image
                    updateSnaphot(with: [menuItem])
                }
            }
        }
    }

    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .news:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsItemCollectionViewCell.reuseIdentifier, for: indexPath) as? NewsItemCollectionViewCell
                cell?.configureCell(item.newsItem.name, nil)
                return cell

            case .menu:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuItemCollectionViewCell.reuseIdentifier, for: indexPath) as? MenuItemCollectionViewCell
                let image: UIImage? = self.imageSource[item.menuItem.id]
                cell?.configureCell(menuItem: item.menuItem, image: image)
                return cell
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as! HeaderReusableView
            headerView.setupView(self.menuHeaders)
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

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

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