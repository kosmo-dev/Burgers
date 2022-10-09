//
//  NewsItem.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 09.10.2022.
//

import Foundation

struct NewsItem: Codable, Hashable {
    let newsDescription: String
    let id: Int
    let name: String
    let photoURL: String
    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case newsDescription = "description"
        case id, name, photoURL, timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        return lhs.id == rhs.id
    }
}
