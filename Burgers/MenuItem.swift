//
//  MenuItem.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import Foundation

struct MenuItem: Codable {
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
}

typealias MenuItems = [String: MenuItem]

struct Test: Codable {
    let test1: String
}
