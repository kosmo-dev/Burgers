//
//  HeaderReusableView.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 08.10.2022.
//

import UIKit

class HeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderReuseIdentifier"

    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupView(_ menuHeaders: [String]) {
        scrollView.backgroundColor = .systemBackground
        addSubview(scrollView)

        scrollView.addSubview(stackView)

//        for i in 0...50 {
//            let label = UILabel()
//            label.translatesAutoresizingMaskIntoConstraints = false
//            label.text = "Label \(i)"
//            label.font = UIFont.systemFont(ofSize: 22, weight: .black)
//
//            stackView.addArrangedSubview(label)
//        }

        for menuHeader in menuHeaders {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(menuHeader)"
            label.font = UIFont.systemFont(ofSize: 22, weight: .black)

            stackView.addArrangedSubview(label)
        }

        setupLayout()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 8),
        ])
    }
}
