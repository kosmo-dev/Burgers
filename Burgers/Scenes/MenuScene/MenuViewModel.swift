//
//  MenuViewModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.09.2023.
//

import Foundation

protocol MenuViewModelProtocol {
    var menuDataSourcePublisher: Published<[String]>.Publisher { get }
    var newsDataSourcePublisher: Published<[String]>.Publisher { get }
    var sectionsPublisher: Published<[MenuViewModel.Section]>.Publisher { get }

    func viewDidLoad()
}

final class MenuViewModel: MenuViewModelProtocol {
    var menuDataSourcePublisher: Published<[String]>.Publisher { $menuDataSource }
    var newsDataSourcePublisher: Published<[String]>.Publisher { $newsDataSource }
    var sectionsPublisher: Published<[Section]>.Publisher { $sections }
    
    @Published private var menuDataSource: [String] = []
    @Published private var newsDataSource: [String] = []
    @Published private var sections: [Section] = []

    func viewDidLoad() {
        menuDataSource = ["Black", "Jack", "Steve", "Steak", "Blake", "Lewis", "Clark", "Greek", "Caesar", "Jucie", "Lemonade"]
        newsDataSource = ["New Burger", "New Lemonade", "2+1 on Friday", "Happy Hours", "New Steak"]
        sections = [.news, .menu]
    }
}

// MARK: - Section Enum
extension MenuViewModel {
    enum Section {
        case news
        case menu
    }
}
