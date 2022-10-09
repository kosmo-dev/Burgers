//
//  HomeViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit
//import FirebaseStorage

class HomeViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, MenuItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MenuItem>

    enum Section {
        case menu
    }

    var requestTask: Task<Void, Never>? = nil

    var menuItems: [MenuItem] = []
    var imageSource: [Int: UIImage] = [:]
    var menuHeaders = ["BURGERS", "SNACKS", "SALADS", "STEAKS", "DRINKS"]

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
                var newDataSource = [MenuItem]()
                for i in menuItemsDecoded {
                    newDataSource.append(i.value)
                }
                self.menuItems = newDataSource
                self.menuItems = self.menuItems.sorted { $0.id < $1.id }
            } else {
                self.menuItems = []

            }
            applySnaphot()

            for menuItem in menuItems {
                if let image = try? await MenuItemImageRequest().send(url: menuItem.photoURL) {
                    imageSource[menuItem.id] = image
                    updateSnaphot(with: [menuItem])
                }
            }
        }
    }

    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, menuItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCollectionViewCell
            let image: UIImage? = self.imageSource[menuItem.id]
            cell?.configureCell(title: menuItem.name, price: menuItem.price, ingredientsDescription: menuItem.ingredientsDescription, image: image)
            return cell
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

        snapshot.appendSections([.menu])
        snapshot.appendItems(menuItems, toSection: .menu)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func updateSnaphot(with items: [MenuItem]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {

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

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}
