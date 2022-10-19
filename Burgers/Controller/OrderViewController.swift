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

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in

            let section = self.sections[sectionIndex]

            switch section {
            case .orders:

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(74))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

                return section

            case .currentOrder:

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

                return section
            }
        }
        return layout
    }

    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .currentOrder:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell
                let image = self.cacheController.images[item.orderItem.menuItem.id] ?? UIImage(systemName: "photo")!
                cell?.configureView(menuItem: item.orderItem.menuItem, numberOfItems: item.orderItem.counts, image: image)
                cell?.delegate = self
                return cell
            case .orders:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderCollectionViewCell
                let status = self.orders[indexPath.row].order.status
                cell?.configureView(status: status)
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
//        Task {
//            var orderRequest = PlaceOrderRequest(orderToPut: orderController.order)
//            orderRequest.path += "/\(UUID())"
//            try await orderRequest.send()
//            orderController.clearOrder()
//        }
        let newOrder = Order(orderItems: orderController.order, status: 1, id: UUID().uuidString)
        orders.append(OrderDataSourceItem.order(newOrder))
        applySnaphot()
        orderController.clearOrder()
        applySnaphot()

        perform(#selector(status2), with: nil, afterDelay: 3)

        perform(#selector(status3), with: nil, afterDelay: 10)
    }

    @objc func status2() {
        let oldOrder = orders.last!
        let newOrder = Order(orderItems: oldOrder.order.orderItems, status: 2, id: oldOrder.order.id)
        orders.removeLast()
        orders.append(OrderDataSourceItem.order(newOrder))
        applySnaphot()
    }

    @objc func status3() {
        let oldOrder = orders.last!
        let newOrder = Order(orderItems: oldOrder.order.orderItems, status: 3, id: oldOrder.order.id)
        orders.removeLast()
        orders.append(OrderDataSourceItem.order(newOrder))
        applySnaphot()
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
