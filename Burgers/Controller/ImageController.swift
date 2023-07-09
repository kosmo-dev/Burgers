//
//  ImageController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 14.10.2022.
//

import UIKit


fileprivate let sharedImageController = ImageController()

protocol ImageControlling {
    var imageController: ImageController {get}
}

extension ImageControlling {
    var imageController: ImageController {
        return sharedImageController
    }
}

final class ImageController {
    private(set) var images: [String: UIImage] = [:]

    let lock = NSLock()

    func fetchImage(url: String) async {
        guard let image = try? await MenuItemImageRequest().send(url: url) else {return}
        lock.lock()
        images[url] = image
        lock.unlock()
    }
}
