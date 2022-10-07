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
}
