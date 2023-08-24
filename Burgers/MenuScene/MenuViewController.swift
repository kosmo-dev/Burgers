//
//  MenuViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.08.2023.
//

import UIKit

class MenuViewController: UIViewController {

    // MARK: - Private Properties
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = S.MenuViewController.title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 37, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

// MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
    }

    // MARK: - Private Methods
    private func configureLayout() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
