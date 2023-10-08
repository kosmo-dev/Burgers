//
//  AppConfiguration.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.08.2023.
//

import UIKit

final class AppConfiguration {
    let menuViewController: UIViewController
    let cartViewController: UIViewController

    init() {
        let networkClient = NetworkClient()
        let imageLoader = ImageLoader(networkClient: networkClient)
        let menuViewModel = MenuViewModel(networkClient: networkClient, imageLoader: imageLoader)
        menuViewController = MenuViewController(viewModel: menuViewModel)
        cartViewController = CartViewController()
    }
}
