//
//  TabBarController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 11.08.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    let appConfiguration: AppConfiguration

    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appConfiguration.menuViewController.tabBarItem = UITabBarItem(title: S.TabBarController.menuViewControllerTitle, image: UIImage(systemName: "menucard"), selectedImage: UIImage(systemName: "menucard.fill"))
        appConfiguration.cartViewController.tabBarItem = UITabBarItem(title: S.TabBarController.cartViewControllerTitle, image:UIImage(systemName: "bag"), selectedImage: UIImage(systemName: "bag.fill"))

        viewControllers = [appConfiguration.menuViewController, appConfiguration.cartViewController]

        tabBar.tintColor = .black
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
