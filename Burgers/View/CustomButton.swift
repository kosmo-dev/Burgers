//
//  CustomButton.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 19.10.2022.
//

import UIKit

final class CustomButton: UIButton {
    init(title: String, action: Selector) {
        super.init(frame: .zero)
        addTarget(nil, action: action, for: .touchUpInside)
        configure(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        isUserInteractionEnabled = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.transform = .identity
        }
        isUserInteractionEnabled = true
    }

    private func configure(title: String) {
        backgroundColor = .black
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}

//    override func awakeFromNib() {
//        self.backgroundColor = .label
//        self.titleLabel?.textColor = .systemBackground
//        self.layer.cornerRadius = 5
//    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        animate()
//    }

//    func animate() {
//        isUserInteractionEnabled = false
//        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear) {
//            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        } completion: { _ in
//            UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear) {
//                self.transform = CGAffineTransform.identity
//            } completion: { _ in
//                self.isUserInteractionEnabled = true
//            }
//        }
//    }
