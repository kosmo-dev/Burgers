//
//  HeaderReusableView.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 08.10.2022.
//

import UIKit

class HeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderReuseIdentifier"

    var scrollView: UIScrollView?
    var stackView: UIStackView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupView(_ menuHeaders: [String]) {
        scrollView = makeScrollView()
        stackView = makeStackView()
        guard let scrollView, let stackView else {return}

        addSubview(scrollView)
        scrollView.addSubview(stackView)
        for menuHeader in menuHeaders {
            stackView.addArrangedSubview(makeLabel(with: menuHeader))
        }
        setupLayout(scrollView, stackView)
    }

    private func setupLayout(_ scrollView: UIScrollView, _ stackView: UIStackView) {
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

    private func makeLabel(with menuHeader: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(menuHeader)"
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)

        return label
    }

    private func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }

    private func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    func scrollViewTo(offset: Int) {
        guard let scrollView else {return}
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}
