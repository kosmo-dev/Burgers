//
//  HomeViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

class HomeViewController: UIViewController {

    var requestTask: Task<Void, Never>? = nil

    var dataSource: [MenuItem] = []
    var imageSource: [Int: UIImage] = [:]

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        update()
    }

    // MARK: Functions

    func update() {
        requestTask?.cancel()

        requestTask = Task {
            print("Start task")
            if let menuItemsDecoded = try? await MenuItemRequest().send() {
                var newDataSource = [MenuItem]()
                for i in menuItemsDecoded {
                    newDataSource.append(i.value)
                }
                self.dataSource = newDataSource
                print("success \(dataSource)")
            } else {
                self.dataSource = []
                print("failed \(dataSource)")
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }

            print("Start downloading photos")
            print(dataSource)
            for menuItem in dataSource {
                print(menuItem.photoURL)
                if let image = try? await MenuItemImageRequest().send(url: menuItem.photoURL) {
                    imageSource[menuItem.id] = image
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
            print(imageSource)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCollectionViewCell else { return UICollectionViewCell() }

        let menuItem = dataSource[indexPath.row]
        let image: UIImage? = imageSource[menuItem.id]
        cell.configureCell(title: menuItem.name, price: menuItem.price, ingredientsDescription: menuItem.ingredientsDescription, image: image)

        return cell
    }


}
