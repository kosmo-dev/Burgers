//
//  OrderItem.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 15.10.2022.
//

import Foundation

struct OrderItem: Codable, Hashable {
    var menuItem: MenuItem
    var counts: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(menuItem.id)
    }

    static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        return lhs.menuItem.id == rhs.menuItem.id && lhs.counts == rhs.counts
    }

    enum CodingKeys: CodingKey {
        case menuItem
        case counts
    }
}
