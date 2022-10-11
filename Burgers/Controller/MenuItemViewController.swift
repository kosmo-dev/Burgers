//
//  MenuItemViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 09.10.2022.
//

import UIKit

class MenuItemViewController: UIViewController, OrderControlling {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var decriptionLabel: UILabel!

    @IBOutlet weak var chooseButton: UIButton!

    var menuItem: MenuItem
    var menuImage: UIImage?

    init?(coder: NSCoder, menuItem: MenuItem, image: UIImage?) {
        self.menuItem = menuItem
        self.menuImage = image
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        itemImageView.image = menuImage ?? UIImage(systemName: "photo")
        titleLabel.text = menuItem.name.uppercased()
        priceLabel.text = "\(menuItem.price) P"
        decriptionLabel.text = menuItem.menuItemDescription
    }

    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        self.orderController.addToOrder(menuItem)
        dismiss(animated: true)
    }
}
