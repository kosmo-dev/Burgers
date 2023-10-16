//
//  MenuItemViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 09.10.2022.
//

import UIKit

//final class MenuItemViewController: UIViewController, OrderControlling {
//
//    var menuItem: MenuItem
//    var menuImage: UIImage?
//
//    // MARK: Outlets
//    @IBOutlet weak var itemImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var chooseButton: UIButton!
//
//    // MARK: View Life Cycle
//    init?(coder: NSCoder, menuItem: MenuItem, image: UIImage?) {
//        self.menuItem = menuItem
//        self.menuImage = image
//        super.init(coder: coder)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//    }
//
//    // MARK: Functions
//    func setupView() {
//        itemImageView.image = menuImage ?? UIImage(systemName: "photo")
//        titleLabel.text = menuItem.name.uppercased()
//        priceLabel.text = "\(menuItem.price) P"
//        descriptionLabel.text = menuItem.menuItemDescription
//    }
//
//    // MARK: Actions
//    @IBAction func chooseButtonTapped(_ sender: UIButton) {
//        orderController.addToOrder(menuItem)
//        dismiss(animated: true)
//    }
//}
