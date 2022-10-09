//
//  MenuItemCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {

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

    func configureCell(title: String, price: Int, ingredientsDescription: String, image: UIImage?) {
        self.title.text = title.uppercased()
        self.price.text = "\(price) P"
        self.ingredientsDescription.text = ingredientsDescription
        self.imageView.image = image ?? UIImage(systemName: "photo")
        print("cell configured")
    }

    // MARK: - Actions
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
    }

}
