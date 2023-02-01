//
//  AlertModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 31.01.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String

    let actionConfirmText: String
    let actionCancelText: String?

    let actionConfirmCompletion: () -> Void
    let actionCancelCompletion: () -> Void
}
