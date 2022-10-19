//
//  CustomButton.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 19.10.2022.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        self.backgroundColor = .label
        self.titleLabel?.textColor = .systemBackground
        self.layer.cornerRadius = 5
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate()
    }

    func animate() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform.identity
            } completion: { _ in
                self.isUserInteractionEnabled = true
            }

        }

    }
}
