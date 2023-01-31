//
//  ItemsFactory.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 31.01.2023.
//

import Foundation

protocol ItemsFactoryProtocol {
    func getMenuAndNewsItems() async
}

protocol ItemsFactoryDelegate: AnyObject {
    func didReceivedItems(menuItems: [Item], newsItems: [Item], menuHeaders: [String])
    func failedReceiveMenuAndNewsItems()
}

class ItemsFactory: ItemsFactoryProtocol {
    private var menuItems = [Item]()
    private var newsItems = [Item]()
    private var menuHeaders = [String]()

    weak private var delegate: ItemsFactoryDelegate?

    init (delegate: ItemsFactoryDelegate?) {
        self.delegate = delegate
    }

    func getMenuAndNewsItems() async {
        do {
            let menuItemsDecoded = try await MenuItemRequest().send()
            for i in menuItemsDecoded {
                menuItems.append(Item.menu(i.value))
            }
            self.menuItems = self.menuItems.sorted(by: {$0.menuItem.id < $1.menuItem.id})
            self.menuHeaders = menuItems.map {$0.menuItem.type.uppercased()}
            self.menuHeaders = menuHeaders.makeUniqueElements()
        } catch {
            delegate?.failedReceiveMenuAndNewsItems()
        }
        do {
            let newsItemsDecoded = try await NewsItemRequest().send()
            for i in newsItemsDecoded {
                newsItems.append(Item.news(i))
            }
            self.newsItems = self.newsItems.sorted(by: {$0.newsItem.timestamp > $1.newsItem.timestamp})
        } catch {
            delegate?.failedReceiveMenuAndNewsItems()
        }
        delegate?.didReceivedItems(menuItems: menuItems, newsItems: newsItems, menuHeaders: menuHeaders)
    }
}
