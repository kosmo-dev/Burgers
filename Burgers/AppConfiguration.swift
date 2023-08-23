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
        menuViewController = MenuViewController()
        cartViewController = CartViewController()
    }
}
