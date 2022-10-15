//
//  OrderViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

class OrderViewController: UIViewController, OrderControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem.image = UIImage(systemName: "bag")
        tabBarItem.selectedImage = UIImage(systemName: "bag.fill")
        tabBarItem.title = "Bag"
        tabBarItem.badgeColor = .label
        orderController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.collectionViewLayout = generateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()

        checkOrderButton()
        checkTotalPrice()
    }

    func numberOfItemsInOrderChanged(_ count: Int) {
        tabBarItem.badgeValue = "\(count)"
        if let collectionView = collectionView {
            collectionView.reloadData()
        }
        if orderController.totalCount == 0 {
            tabBarItem.badgeValue = nil
        }
        checkOrderButton()
        checkTotalPrice()
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .absolute(230))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        group.interItemSpacing = .fixed(8)
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }

    @IBAction func placeOrderButtonTapped(_ sender: UIButton) {
    }

    func checkOrderButton() {
        guard let placeOrderButton = placeOrderButton else {return}
        if orderController.totalCount > 0 {
            placeOrderButton.isHidden = false
        } else {
            placeOrderButton.isHidden = true
        }
    }
    func checkTotalPrice() {
        guard let totalPriceLabel = totalPriceLabel else {return}
        if orderController.totalCount > 0 {
            totalPriceLabel.isHidden = false
            totalLabel.isHidden = false
            totalPriceLabel.text = "\(orderController.countTotalPrice()) P"
        } else {
            totalPriceLabel.isHidden = true
            totalLabel.isHidden = true
        }
    }
}

extension OrderViewController: UICollectionViewDataSource, UICollectionViewDelegate, OrderControlling, CacheControlling {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderController.order.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderCollectionViewCell
        let orderItem = orderController.order[indexPath.row]
        let image = cacheController.images[orderItem.menuItem.id] ?? UIImage(systemName: "photo")!
        cell?.setupView(menuItem: orderItem.menuItem, numberOfItems: orderItem.counts, image: image)
        cell?.delegate = self
        return cell ?? UICollectionViewCell()
    }
}

extension OrderViewController: OrderCollectionViewCellDelegate {
    func addItemButtonTapped(item: MenuItem) {
        orderController.addToOrder(item)
    }

    func removeItemButtonTapped(item: MenuItem) {
        orderController.removeFromOrder(item)
    }


}
