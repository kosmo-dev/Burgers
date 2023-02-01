//
//  OrderViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

final class OrderViewController: UIViewController, OrderControlling, ImageControlling {

    // MARK: Outlets
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var placeOrderButton: UIButton!
    @IBOutlet weak private var totalPriceLabel: UILabel!
    @IBOutlet weak private  var totalLabel: UILabel!


    // MARK: - Private Properties
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, OrderDataSourceItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, OrderDataSourceItem>

    private enum Section {
        case orders
        case currentOrder
    }
    private var sections: [Section] = []
    lazy private var dataSource = configureDataSource()

    private var orders: [OrderDataSourceItem] = []
    private var currentOrderItem: [OrderDataSourceItem] = []

    // MARK: - Initializers
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem.image = UIImage(systemName: "bag")
        tabBarItem.selectedImage = UIImage(systemName: "bag.fill")
        tabBarItem.title = "Bag"
        tabBarItem.badgeColor = .label
        orderController.delegate = self
    }

    // MARK: - Life Cycle Methods
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

    // MARK: - Actions
    @IBAction private func placeOrderButtonTapped(_ sender: UIButton) {
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

    // MARK: - Private Functions
    private func checkOrderButton() {
        guard let placeOrderButton = placeOrderButton else {return}
        if orderController.totalCount > 0 {
            placeOrderButton.isHidden = false
        } else {
            placeOrderButton.isHidden = true
        }
    }

    private func checkTotalPrice() {
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

    private func updateLastOrderInfo() {
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

    // MARK: - Segue Actions
    @IBSegueAction private func showOrderDetails(_ coder: NSCoder, sender: UICollectionViewCell?) -> OrderDetailViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath)?.order else {return nil}
        return OrderDetailViewController(coder: coder, order: item)
    }

}

// MARK: - Configure Data Source
extension OrderViewController {
    private func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in

            let section = self.sections[indexPath.section]

            switch section {
            case .currentOrder:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderItemCollectionViewCell.reuseIdentifier, for: indexPath) as? OrderItemCollectionViewCell
                let image = self.imageController.images[item.orderItem.menuItem.photoCompressedURL] ?? UIImage(systemName: "photo")!
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

    private func applySnaphot() {
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
extension OrderViewController: UserControlling {}

// MARK: - Compositional Layout
extension OrderViewController {
    private func generateLayout() -> UICollectionViewLayout {
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

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "OrdersHeader", alignment: .top)
                headerItem.contentInsets = NSDirectionalEdgeInsets(top: -8, leading: 8, bottom: -8, trailing: 8)

                section.boundarySupplementaryItems = [headerItem]

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

}
