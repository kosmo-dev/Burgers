//
//  NewsItemCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 24.08.2023.
//

import UIKit
import Combine

final class NewsItemCell: UICollectionViewCell, ReuseIdentifying {
    var imageCancellable: AnyCancellable?

    // MARK: - Private Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let title: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
        title.textColor = .white
        title.shadowColor = .black
        title.shadowOffset = CGSize(width: 1, height: 1)
        title.textAlignment = .natural
        title.numberOfLines = 2
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configureCell(text: String) {
        title.text = text
    }

    func assignImage(_ image: UIImage?) {
        imageView.image = image
    }

    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "photo")
        imageCancellable?.cancel()
    }

    // MARK: - Private Methods
    private func configureView() {
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor

        [imageView, title].forEach { addSubview($0)}

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            title.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}