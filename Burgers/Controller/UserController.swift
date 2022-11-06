//
//  UserController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 06.11.2022.
//

import Foundation

fileprivate let sharedUserController = UserController()

protocol UserControlling {
    var userController: UserController {get}
}

extension UserControlling {
    var userController: UserController {
        return sharedUserController
    }
}

final class UserController {

    private var userId: String?

    private enum UserDefaultsKey: String {
        case uid
    }

    private let userDefaults: UserDefaults = .standard


    func getUserId() -> String {
        if let userId {
            return userId
        } else {
            if let uid = retrieveUserId() {
                return uid
            } else {
                let uid = UUID().uuidString
                saveUserId(uid)
                return uid
            }
        }
    }

    private func retrieveUserId() -> String? {
        let retrievedUid = userDefaults.value(forKey: UserDefaultsKey.uid.rawValue) as? String
        guard let retrievedUid else {return nil}
        userId = retrievedUid
        return userId
    }

    private func saveUserId(_ uid: String) {
        userDefaults.set(uid, forKey: UserDefaultsKey.uid.rawValue)
    }
    
}
