//
//  MenuItem.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import Foundation

struct MenuItem: Codable, Hashable {
    let menuItemDescription: String
    let id: Int
    let ingredientsDescription: String
    let name: String
    let photoURL: String
    let price: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case menuItemDescription = "description"
        case id, ingredientsDescription, name, photoURL, price, type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
