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

    // MARK: Actions
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
                cell?.configureView(status: status)
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
