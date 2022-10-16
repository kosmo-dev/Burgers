//
//  OrderDataSourceItem.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 16.10.2022.
//

import Foundation

enum OrderDataSourceItem: Hashable {

    case orderItem(OrderItem)
    case order(Order)

    var orderItem: OrderItem {
        if case .orderItem(let orderItem) = self {
            return orderItem
        } else {
            return OrderItem(menuItem: MenuItem(menuItemDescription: "", id: 0, ingredientsDescription: "", name: "", photoURL: "", photoCompressedURL: "", price: 0, type: ""), counts: 0)
        }
    }

    var order: Order {
        if case .order(let order) = self {
            return order
        } else {
            return Order(orderItems: [OrderItem(menuItem: MenuItem(menuItemDescription: "", id: 0, ingredientsDescription: "", name: "", photoURL: "", photoCompressedURL: "", price: 0, type: ""), counts: 0)], status: 0, id: "\(UUID())")
        }
    }
}
