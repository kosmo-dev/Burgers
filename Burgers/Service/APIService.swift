//
//  APIService.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 06.10.2022.
//

import Foundation
import UIKit

struct MenuItemRequest: APIRequest {
    
    typealias Response = [String: MenuItem]
    var path: String = "/menu"
    var requestType: APIRequestType = .data
}

struct NewsItemRequest: APIRequest {
    typealias Response = [NewsItem]
    var path: String = "/news"
    var requestType: APIRequestType = .data
}

struct MenuItemImageRequest {
    func send(url: String) async throws -> UIImage {

        guard let url = URL(string: url) else {return UIImage(systemName: "photo")!}
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw ImageRequestError.imageDataMissing}
        guard let image = UIImage(data: data) else { throw ImageRequestError.couldNotInitializeFromData}

        return image
    }
}
