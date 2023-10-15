//
//  ImageLoader.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 08.10.2023.
//

import Foundation
import Combine
import UIKit

protocol ImageLoaderProtocol {
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage?, Never>
}

final class ImageLoader: ImageLoaderProtocol {
    private var cache = NSCache<NSString, UIImage>()

    private var networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        return networkClient.fetchImage(urlString)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] image in
                if let image {
                    self?.cache.setObject(image, forKey: urlString as NSString)
                }
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
