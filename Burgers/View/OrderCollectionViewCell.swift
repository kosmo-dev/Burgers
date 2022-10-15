//
//  BagCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

protocol OrderCollectionViewCellDelegate {
    func addItemButtonTapped(item: MenuItem)
    func removeItemButtonTapped(item: MenuItem)
}

class OrderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "OrderCollectionViewCellReuseIdentifier"

    var delegate: OrderCollectionViewCellDelegate?
    var menuItem: MenuItem?

    @IBOutlet weak var menuItemTitleLabel: UILabel!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var addItemButtonTapped: UIButton!
    @IBOutlet weak var removeItemButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
    }

    func setupView(menuItem: MenuItem, numberOfItems: Int, image: UIImage) {
        menuItemTitleLabel.text = menuItem.name
        numberOfItemsLabel.text = "\(numberOfItems)"
        menuItemImageView.image = image
        priceLabel.text = "\(menuItem.price * numberOfItems) P"
        self.menuItem = menuItem
    }

    @IBAction func addItemButtonTapped(_ sender: UIButton) {
        guard let menuItem else {return}
        delegate?.addItemButtonTapped(item: menuItem)
    }
    @IBAction func removeItemButtonTapped(_ sender: UIButton) {
        guard let menuItem else {return}
        delegate?.removeItemButtonTapped(item: menuItem)
    }
}
