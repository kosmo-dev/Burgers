//
//  HeaderReusableView.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 08.10.2022.
//

import UIKit

protocol HeaderReusableViewDelegate: AnyObject {
    func headerLabelWasTapped(_ header: String)
}

class HeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderReuseIdentifier"

    private var scrollView: UIScrollView?
    private var stackView: UIStackView?
    private var currentOffset: CGFloat = 0
    private var lastmenuItemIndex = 0
    private var lastHeader = ""
    private var dictionaryDidSet = false

    private var headersArray: [HeaderProperty] = []

    weak var delegate: HeaderReusableViewDelegate?

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
            let label = makeLabel(with: menuHeader)
            stackView.addArrangedSubview(label)
            layoutIfNeeded()
            if !dictionaryDidSet {
                headersArray.append(HeaderProperty(header: menuHeader, width: label.bounds.width))
            }
        }
        setupLayout(scrollView, stackView)
        dictionaryDidSet = true
        if let firstHeader = menuHeaders.first {
            lastHeader = firstHeader.lowercased()
        }
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

        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        label.addGestureRecognizer(tap)

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
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    @objc func labelTapped(sender: UITapGestureRecognizer) {
        guard sender.state == .ended,
              let label = sender.view as? UILabel,
              let header = label.text else {return}
        delegate?.headerLabelWasTapped(header)
    }

    func scrollViewTo(header: String, index: Int) {
        guard let scrollView else {return}
        guard header != lastHeader else {return}
        guard let headerIndex = headersArray.firstIndex(where: {$0.header == header.uppercased()}) else {return}
        var offset: CGFloat = 0
        let headerOffset = headersArray.prefix(headerIndex).reduce(into: 0) { partialResult, headerProperty in
            partialResult = partialResult + headerProperty.width
        }
        offset = headerOffset + CGFloat(headerIndex) * (stackView?.spacing ?? 0)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        currentOffset = offset
        lastmenuItemIndex = index
        lastHeader = header
    }

    struct HeaderProperty {
        let header: String
        let width: CGFloat
    }
}
