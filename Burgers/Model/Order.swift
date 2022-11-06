//
//  Order.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 16.10.2022.
//

import Foundation

struct Order: Hashable, Codable {
    var orderItems: [OrderItem]
    var status: Int
    var date: Double
    var counter: Int
    var id: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status
    }

    enum CodingKeys: String, CodingKey {
        case orderItems
        case status
        case date
        case counter
        case id
    }
}
