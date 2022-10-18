//
//  OrderCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 16.10.2022.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "OrderCollectionViewCellReuseIdentifier"

    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var processingOrderImageView: UIImageView!
    @IBOutlet weak var orderTitle: UILabel!


    func configureView(status: Int) {
        switch status {
        case 1:
            configureDefaultView("Order accepted")
        case 2:
            configureDefaultView("Preparing order")
            processingOrderImageView.image = UIImage(systemName: "hourglass")
            processingOrderImageView.tintColor = .systemBackground
            processingOrderImageView.isHidden = false
            Task {
                await startAnimatingImageView()
            }
        case 3:
            configureDefaultView("Order is ready")
            orderStatusLabel.text = "Order is ready"
            backgroundColor = .systemGreen
            orderStatusLabel.textColor = .systemBackground
            orderTitle.textColor = .systemBackground
        default:
            configureDefaultView("Sending order")
        }
    }

    private func configureDefaultView(_ text: String) {
        backgroundColor = .label
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 2
        orderStatusLabel.text = text
        orderStatusLabel.textColor = .systemBackground
        orderTitle.textColor = .systemBackground
        processingOrderImageView.isHidden = true
    }


    private func startAnimatingImageView() async {
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat], animations: {
            self.processingOrderImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: nil)
    }

    private func stopAnimatingImageView() {
        processingOrderImageView.layer.removeAllAnimations()
    }
}
