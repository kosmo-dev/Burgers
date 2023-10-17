//
//  NewsItemViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 10.10.2022.
//

//import UIKit
//
//class NewsItemViewController: UIViewController {
//
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var newsImageView: UIImageView!
//    @IBOutlet weak var newsDescriptionTextView: UITextView!
//
//    var newsItem: NewsItem
//    var image: UIImage?
//
//    init?(coder: NSCoder, newsItem: NewsItem, image: UIImage?) {
//        self.newsItem = newsItem
//        self.image = image
//        super.init(coder: coder)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        titleLabel.text = newsItem.name.uppercased()
//        newsImageView.image = image ?? UIImage(systemName: "photo")
//        newsDescriptionTextView.text = newsItem.newsDescription
//    }
//
//}
