//
//  MenuItemCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 24.08.2023.
//

import UIKit

final class MenuItemCell: UICollectionViewCell, ReuseIdentifying {
    // MARK: - Private properties
    private let verticalStackView: UIStackView = {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        verticalStackView.alignment = .leading
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        return verticalStackView
    }()

    private let title: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 22, weight: .black)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private let priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        priceLabel.textColor = .label
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        return priceLabel
    }()

    private let menuDescription: UILabel = {
        let menuDescription = UILabel()
        menuDescription.font = UIFont.systemFont(ofSize: 11, weight: .light)
        menuDescription.numberOfLines = 2
        menuDescription.textColor = .label
        menuDescription.translatesAutoresizingMaskIntoConstraints = false
        return menuDescription
    }()

    private let chooseButton = CustomButton(
        title: S.MenuViewController.chooseButtonTitle,
        action: #selector(chooseButtonTapped)
    )

    private let menuImageView: UIImageView = {
        let menuImageView = UIImageView()
        menuImageView.image = UIImage(systemName: "photo")
        menuImageView.contentMode = .scaleAspectFit
        menuImageView.tintColor = .black
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        return menuImageView
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods
    func configureCell(text: String) {
        title.text = text
        priceLabel.text = "500 P"
        menuDescription.text = "Loren ipsum dolor set ami, loren ipsum dolor set ami"
    }

    // MARK: - Private methods
    private func configureLayout() {
        [verticalStackView, menuImageView].forEach { addSubview($0) }
        [title, priceLabel, menuDescription, chooseButton].forEach { verticalStackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: menuImageView.leadingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            menuImageView.topAnchor.constraint(equalTo: topAnchor),
            menuImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            menuImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            verticalStackView.widthAnchor.constraint(equalTo: menuImageView.widthAnchor, multiplier: 0.8),
            chooseButton.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor, multiplier: 0.5)
        ])
    }

    @objc private func chooseButtonTapped() {
        print("Button tapped")
    }
}
