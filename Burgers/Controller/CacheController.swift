//
//  CacheController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit


fileprivate let sharedCacheController = CacheController()

protocol CacheControlling {
    var cacheController: CacheController {get}
}

extension CacheControlling {
    var cacheController: CacheController {
        return sharedCacheController
    }
}

final class CacheController {
    private(set) var images: [Int: UIImage] = [:]

    func addToImages(_ image: UIImage, for key: Int) {
        images[key] = image
    }
}
