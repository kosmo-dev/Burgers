//
//  HeaderCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 10.10.2023.
//

import UIKit

final class HeaderCell: UICollectionViewCell, ReuseIdentifying {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Header"
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(text: String) {
        label.text = text
    }

    private func configureLayout() {
        backgroundColor = .white

        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}