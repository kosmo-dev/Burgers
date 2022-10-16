//
//  Order.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 16.10.2022.
//

import Foundation

struct Order: Hashable {
    var orderItems: [OrderItem]
    var status: Int
    var id: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}
