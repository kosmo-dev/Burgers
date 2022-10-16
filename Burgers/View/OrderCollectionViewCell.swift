//
//  OrderCollectionViewCell.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 16.10.2022.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "OrderCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var orderStatusLabel: UILabel!

    func configureView() {
        orderStatusLabel.text = "Order was placed"
    }
}
