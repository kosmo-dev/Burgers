//
//  Item.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 09.10.2022.
//

import Foundation

enum Item: Hashable {
    case news(NewsItem)
    case menu(MenuItem)

    var newsItem: NewsItem {
        if case .news(let newsItem) = self {
            return newsItem
        } else {
            return NewsItem(newsDescription: "", id: 0, name: "", photoURL: "", timestamp: 0)
        }
    }

    var menuItem: MenuItem {
        if case .menu(let menuItem) = self {
            return menuItem
        } else {
            return MenuItem(menuItemDescription: "", id: 0, ingredientsDescription: "", name: "", photoURL: "", photoCompressedURL: "", price: 0, type: "")
        }
    }
}
