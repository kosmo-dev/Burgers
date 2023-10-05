//
//  MenuViewModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.09.2023.
//

import Foundation
import Combine

protocol MenuViewModelProtocol {
    var menuDataSourcePublisher: Published<[MenuItem]>.Publisher { get }
    var newsDataSourcePublisher: Published<[NewsItem]>.Publisher { get }
    var sectionsPublisher: Published<[MenuViewModel.Section]>.Publisher { get }

    func viewDidLoad()
}

final class MenuViewModel: MenuViewModelProtocol {
    var menuDataSourcePublisher: Published<[MenuItem]>.Publisher { $menuDataSource }
    var newsDataSourcePublisher: Published<[NewsItem]>.Publisher { $newsDataSource }
    var sectionsPublisher: Published<[Section]>.Publisher { $sections }
    
    @Published private var menuDataSource: [MenuItem] = []
    @Published private var newsDataSource: [NewsItem] = []
    @Published private var sections: [Section] = []

    var menuCancellable: AnyCancellable?
    var newsCancellable: AnyCancellable?
    let menuRequest = MenuRequest()
    let newsRequest = NewsRequest()
    let client = NetworkClient()

    func viewDidLoad() {
        sections = [.news, .menu]

        menuCancellable = client
            .send(request: menuRequest, type: [String: MenuItem].self)
            .map { items in
                var menu: [MenuItem] = []
                items.forEach { menu.append($0.value) }
                menu.sort(by: {$0.id < $1.id} )
                return menu
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .sink(receiveValue: { [weak self] menu in
                self?.menuDataSource = menu
            })

        newsCancellable = client
            .send(request: newsRequest, type: [NewsItem].self)
            .map { news in
                return news.sorted(by: { $0.id < $1.id })
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .sink(receiveValue: { [weak self] news in
                self?.newsDataSource = news
            })
    }
}

// MARK: - Section Enum
extension MenuViewModel {
    enum Section {
        case news
        case menu
    }
}

struct MenuRequest: NetworkRequest {
    var endpoint: URL? = URL(string: "https://burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app/menu.json")
}

struct NewsRequest: NetworkRequest {
    var endpoint: URL? = URL(string: "https://burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app/news.json")
}
