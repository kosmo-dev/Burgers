//
//  NewsItemViewModel.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 17.10.2023.
//

import UIKit
import Combine

protocol NewsItemViewModelProtocol {
    var newsItem: NewsItem? { get }
    var newsItemPublisher: Published<NewsItem?>.Publisher { get }
    var imagePublisher: Published<UIImage?>.Publisher { get }
}

final class NewsItemViewModel: NewsItemViewModelProtocol {
    @Published private(set) var newsItem: NewsItem?
    @Published private(set) var image: UIImage?

    var newsItemPublisher: Published<NewsItem?>.Publisher { $newsItem }
    var imagePublisher: Published<UIImage?>.Publisher { $image }

    private var imageLoader: ImageLoaderProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(imageLoader: ImageLoaderProtocol, newsItem: NewsItem) {
        self.imageLoader = imageLoader
        setNewsItem(newsItem)
    }

    private func setNewsItem(_ newsItem: NewsItem) {
        self.newsItem = newsItem
        imageLoader.fetchImage(from: newsItem.photoURL)
            .sink { [weak self] image in
                self?.image = image
            }.store(in: &cancellables)
    }
}
