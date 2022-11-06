//
//  OrderViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

class OrderViewController: UIViewController, OrderControlling, CacheControlling {

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

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    // MARK: View Life Cycle
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
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: "OrdersHeader", withReuseIdentifier: HeaderReusableView.reuseIdentifier)

        updateLastOrderInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnaphot()
        checkOrderButton()
        checkTotalPrice()
    }


    // MARK: Functions
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

    func updateLastOrderInfo() {
        Task {
            orders.removeAll()
            var lastOrderRequest = LastOrdersRequest()
            lastOrderRequest.path += "/\(userController.getUserId())"
            let lastOrdersDecoded = try await lastOrderRequest.send()
            for orderId in lastOrdersDecoded {
                orders.append(OrderDataSourceItem.order(orderId.value))
            }
            orders.sort(by: { $0.order.date > $1.order.date })
            applySnaphot()
        }
    }

    // MARK: Actions
    @IBAction func placeOrderButtonTapped(_ sender: UIButton) {
        let uid = userController.getUserId()
        let orderId = UUID().uuidString
        let newOrder = Order(orderItems: orderController.order, status: 1, date: Date().timeIntervalSince1970, counter: orders.count + 1, id: orderId)
        Task {
            var orderRequest = PlaceOrderRequest(orderToPut: newOrder)
            orderRequest.path += "/\(uid)/\(orderId)"
            try await orderRequest.send()
            orders.insert(OrderDataSourceItem.order(newOrder), at: 0)
            applySnaphot()
            orderController.clearOrder()
            applySnaphot()
        }
    }
}

// MARK: - Configure Data Source
extension OrderViewController {
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
                let counter = self.orders[indexPath.row].order.counter
                cell?.configureView(status: status, id: counter)
                return cell
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "OrdersHeader", withReuseIdentifier: HeaderReusableView.reuseIdentifier, for: indexPath) as? HeaderReusableView
            if let headerView {
                headerView.setupViewWithOneLabel("LAST ORDERS")
            }
            return headerView

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
}

// MARK: - OrderControllerDelegate
extension OrderViewController: OrderControllerDelegate {
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
}

// MARK:  - OrderItemCollectionViewCellDelegate
extension OrderViewController: OrderItemCollectionViewCellDelegate {
    func addItemButtonTapped(item: MenuItem) {
        orderController.addToOrder(item)
    }

    func removeItemButtonTapped(item: MenuItem) {
        orderController.removeFromOrder(item)
    }
}


// MARK: - UserControlling
extension OrderViewController: UserControlling {
}
