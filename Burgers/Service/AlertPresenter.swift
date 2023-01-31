//
//  AlertPresenter.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 31.01.2023.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

protocol AlertPresenterDelegate: AnyObject {
    func presentAlertView(alert: UIAlertController)
}


struct AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?

    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }

    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: alertModel.actionConfirmText, style: .default) { _ in
            alertModel.actionConfirmCompletion()
        }
        alert.addAction(confirmAction)
        if alertModel.actionCancelText != nil {
            let cancelAction = UIAlertAction(title: alertModel.actionCancelText, style: .cancel) { _ in
                alertModel.actionCancelCompletion()
            }
            alert.addAction(cancelAction)
        }
        delegate?.presentAlertView(alert: alert)
    }
}
