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

    lazy var dataSource = configureDataSource()

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = generateLayout()
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

        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
