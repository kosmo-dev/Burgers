//
//  MenuNetworkRequest.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2023.
//

import Foundation

struct MenuRequest: NetworkRequest {
    var endpoint: URL? = URL(string: "https://burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app/menu.json")
}

struct NewsRequest: NetworkRequest {
    var endpoint: URL? = URL(string: "https://burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app/news.json")
}

struct ImageRequest: NetworkRequest {
    var endpoint: URL?
}
