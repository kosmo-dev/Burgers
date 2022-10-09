//
//  NewsItemCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 09.10.2022.
//

import UIKit

class NewsItemCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "NewsCellReuseIdentifier"

    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(_ title: String?, _ image: UIImage?) {
        newsImageView.tintColor = .label
        titleLabel.backgroundColor = .systemBackground

        if let title {
            titleLabel.text = title
        } else {
            titleLabel.text = ""
        }
        
        if let image {
            newsImageView.image = image
        } else {
            newsImageView.image = UIImage(systemName: "photo")
        }
    }
}
