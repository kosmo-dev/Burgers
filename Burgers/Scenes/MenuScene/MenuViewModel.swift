//
//  MenuViewModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.09.2023.
//

import UIKit
import Combine

protocol MenuViewModelProtocol {
    var menu: [MenuItem] { get }
    var news: [NewsItem] { get }
    var sections: [MenuViewModel.Section] { get }

    var menuDataSourcePublisher: Published<[MenuItem]>.Publisher { get }
    var newsDataSourcePublisher: Published<[NewsItem]>.Publisher { get }
    var sectionsPublisher: Published<[MenuViewModel.Section]>.Publisher { get }

    var delegate: MenuViewModelPresentationDelegate? { get set }

    func viewDidLoad()
    func fetchImage(for urlString: String) -> AnyPublisher<UIImage?, Never>
    func menuCellTapped(at indexPath: IndexPath)
}

protocol MenuViewModelPresentationDelegate: AnyObject {
    func present(viewController: UIViewController)
}

final class MenuViewModel: MenuViewModelProtocol {
    @Published private(set) var menu: [MenuItem] = []
    @Published private(set) var news: [NewsItem] = []
    @Published private(set) var sections: [Section] = []

    var menuDataSourcePublisher: Published<[MenuItem]>.Publisher { $menu }
    var newsDataSourcePublisher: Published<[NewsItem]>.Publisher { $news }
    var sectionsPublisher: Published<[Section]>.Publisher { $sections }

    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: MenuViewModelPresentationDelegate?

    let networkClient: NetworkClientProtocol
    let imageLoader: ImageLoaderProtocol
    let menuRequest = MenuRequest()
    let newsRequest = NewsRequest()

    init(networkClient: NetworkClientProtocol, imageLoader: ImageLoaderProtocol) {
        self.networkClient = networkClient
        self.imageLoader = imageLoader
    }

    func viewDidLoad() {
        sections = [.news, .menu]

        networkClient.send([String: MenuItem].self, request: menuRequest)
            .map { items in
                var menu: [MenuItem] = []
                items.forEach { menu.append($0.value) }
                menu.sort(by: {$0.id < $1.id} )
                return menu
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Completed")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { [weak self] menu in
                self?.menu = menu
            }
            .store(in: &cancellables)

        networkClient.send([NewsItem].self, request: newsRequest)
            .map { news in
                return news.sorted(by: { $0.id < $1.id })
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Completed")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { [weak self] news in
                self?.news = news
            }
            .store(in: &cancellables)
    }

    func menuCellTapped(at indexPath: IndexPath) {
        let menuItem = menu[indexPath.item]
        let viewModel = MenuItemViewModel(imageLoader: imageLoader, menuItem: menuItem)
        let viewController = MenuItemViewController(viewModel: viewModel)
        delegate?.present(viewController: viewController)
    }

    func fetchImage(for urlString: String) -> AnyPublisher<UIImage?, Never> {
        imageLoader.fetchImage(from: urlString)
    }
}

// MARK: - Section Enum
extension MenuViewModel {
    enum Section {
        case news
        case menu
    }
}
