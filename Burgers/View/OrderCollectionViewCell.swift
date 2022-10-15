//
//  BagCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "OrderCollectionViewCellReuseIdentifier"

    @IBOutlet weak var menuItemTitleLabel: UILabel!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var menuItemImageView: UIImageView!

    override func awakeFromNib() {
    }

    func setupView(menuItem: MenuItem, numberOfItems: Int, image: UIImage) {
        menuItemTitleLabel.text = menuItem.name
        numberOfItemsLabel.text = "\(numberOfItems)"
        menuItemImageView.image = image
    }

}
