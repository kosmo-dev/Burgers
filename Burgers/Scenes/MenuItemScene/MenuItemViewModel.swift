//
//  MenuItemViewModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 15.10.2023.
//

import UIKit
import Combine

protocol MenuItemViewModelProtocol {
    var menuItem: MenuItem? { get }
    var menuItemPublisher: Published<MenuItem?>.Publisher { get }
    var imagePublisher: Published<UIImage?>.Publisher { get }
}

final class MenuItemViewModel: MenuItemViewModelProtocol {
    @Published private(set) var menuItem: MenuItem?
    @Published private(set) var image: UIImage?

    var menuItemPublisher: Published<MenuItem?>.Publisher { $menuItem }
    var imagePublisher: Published<UIImage?>.Publisher { $image }

    private var imageLoader: ImageLoaderProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(imageLoader: ImageLoaderProtocol, menuItem: MenuItem) {
        self.imageLoader = imageLoader
        setMenuItem(menuItem)
    }

    private func setMenuItem(_ menuItem: MenuItem) {
        self.menuItem = menuItem
        imageLoader.fetchImage(from: menuItem.photoCompressedURL)
            .sink { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }
}
