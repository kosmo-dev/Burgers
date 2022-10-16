//
//  OrderViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

class OrderViewController: UIViewController, OrderControllerDelegate, OrderControlling, CacheControlling {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    typealias DataSource = UICollectionViewDiffableDataSource<Section, OrderDataSourceItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, OrderDataSourceItem>

    enum Section {
        case orders
        case currentOrder
    }
    var sections: [Section] = []
    lazy var dataSource = configureDataSource()

    var orders: [OrderDataSourceItem] = []
    var currentOrderItem: [OrderDataSourceItem] = []

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

        applySnaphot()

        collectionView.collectionViewLayout = generateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applySnaphot()

        checkOrderButton()
        checkTotalPrice()
    }

    func numberOfItemsInOrderChanged(_ count: Int) {
        tabBarItem.badgeValue = "\(count)"
        currentOrderItem = orderController.order.map({OrderDataSourceItem.orderItem($0)})

        if collectionView != nil {
            applySnaphot()
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

    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .currentOrder:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell
                let image = self.cacheController.images[item.orderItem.menuItem.id] ?? UIImage(systemName: "photo")!
                cell?.configureView(menuItem: item.orderItem.menuItem, numberOfItems: item.orderItem.counts, image: image)
                print(item.orderItem.counts)
                cell?.delegate = self
                return cell
            case .orders:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderCollectionViewCell
                cell?.configureView()
                return cell
            }
        }
        return dataSource
    }

    func applySnaphot() {
        var snapshot = Snapshot()

        snapshot.appendSections([.currentOrder, .orders])
        snapshot.appendItems(currentOrderItem, toSection: .currentOrder)
        snapshot.appendItems(orders, toSection: .orders)

        sections = snapshot.sectionIdentifiers

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func updateSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.currentOrder])

        dataSource.apply(snapshot, animatingDifferences: true)
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

    @IBAction func placeOrderButtonTapped(_ sender: UIButton) {
        Task {
            var orderRequest = PlaceOrderRequest(orderToPut: orderController.order)
            orderRequest.path += "/\(UUID())"
            try await orderRequest.send()
            orderController.clearOrder()
        }
    }
}

extension OrderViewController: OrderItemCollectionViewCellDelegate {
    func addItemButtonTapped(item: MenuItem) {
        orderController.addToOrder(item)
    }

    func removeItemButtonTapped(item: MenuItem) {
        orderController.removeFromOrder(item)
    }


}
