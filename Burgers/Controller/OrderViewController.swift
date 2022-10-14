//
//  OrderViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

class OrderViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeOrderButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.collectionViewLayout = generateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBAction func placeOrderButtonTapped(_ sender: UIButton) {
    }
}

extension OrderViewController: UICollectionViewDataSource, UICollectionViewDelegate, OrderControlling, CacheControlling {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderController.order.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderCollectionViewCell
        let menuItem = orderController.order[indexPath.row]
        let image = cacheController.images[menuItem.id] ?? UIImage(systemName: "photo")!
        cell?.setupView(menuItem: menuItem, numberOfItems: 1, image: image)
        return cell ?? UICollectionViewCell()
    }


}
