//
//  OrderDetailViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 06.11.2022.
//

import UIKit

class OrderDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var orderDate: UILabel!

    var order: Order

    init?(coder: NSCoder, order: Order) {
        self.order = order
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        orderNumber.text = "ORDER \(order.counter)"
        orderDate.text = "Order date \(formatDate(order.date))"

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        var group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .absolute(230))
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        } else {
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(230))
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        }
        group.interItemSpacing = .fixed(8)
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension OrderDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        order.orderItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell
        let orderItem = order.orderItems[indexPath.row]
        var image = UIImage()
        if let fetchedImage = self.imageController.images[orderItem.menuItem.photoCompressedURL] {
            image = fetchedImage
        } else {
            image = UIImage(systemName: "photo")!
            Task {
                await backgroundPhotoUpdate(url: orderItem.menuItem.photoCompressedURL)
            }
        }
        cell?.configureView(menuItem: orderItem.menuItem, numberOfItems: orderItem.counts, image: image)
        cell?.removeButtons()
        return cell ?? UICollectionViewCell()
    }

    func backgroundPhotoUpdate(url: String) async {
        await imageController.fetchImage(url: url)
        collectionView.reloadData()
    }
}

extension OrderDetailViewController: ImageControlling {
}

extension OrderDetailViewController {
    func formatDate(_ timeIntervalSince1970: Double) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_Ru")
        formatter.dateFormat = "HH:mm dd.MM.yy"
        let date = formatter.string(from: Date(timeIntervalSince1970: timeIntervalSince1970))
        return date
    }
}
