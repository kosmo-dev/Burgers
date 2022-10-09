//
//  MenuItemCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MenuItemCellReuseIdentifier"

    // MARK: - Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var ingredientsDescription: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(menuItem: MenuItem?, image: UIImage?) {
        if let menuItem {
            self.title.text = menuItem.name.uppercased()
            self.price.text = "\(menuItem.price) P"
            self.ingredientsDescription.text = menuItem.ingredientsDescription
        }
        self.imageView.image = image ?? UIImage(systemName: "photo")
    }

    // MARK: - Actions
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
    }

}
