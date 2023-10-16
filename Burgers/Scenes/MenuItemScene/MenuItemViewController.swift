//
//  MenuItemViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 15.10.2023.
//

import UIKit
import Combine

final class MenuItemViewController: UIViewController {
    // MARK: - Private Properties
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .black)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private let priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 28, weight: .light)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        return priceLabel
    }()

    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()

    private let image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let chooseButton = CustomButton(title: "Choose", action: #selector(chooseButtonTapped))

    private var viewModel: MenuItemViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    init(viewModel: MenuItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureSubscription()
    }

    // MARK: - Private Methods
    private func configureLayout() {
        view.backgroundColor = .white

        [titleLabel, priceLabel, descriptionLabel, image, chooseButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 140),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            image.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 1),

            descriptionLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            chooseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            chooseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            chooseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            chooseButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }

    private func configureSubscription() {
        viewModel.menuItemPublisher.sink { [weak self] item in
            guard let self, let item else { return }
            self.titleLabel.text = item.name
            self.priceLabel.text = "\(item.price) P"
            self.descriptionLabel.text = item.menuItemDescription
        }.store(in: &cancellables)

        viewModel.imagePublisher.sink { [weak self] image in
            self?.image.image = image
        }.store(in: &cancellables)
    }

    @objc private func chooseButtonTapped() {
        dismiss(animated: true)
    }
}


