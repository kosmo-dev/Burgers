//
//  APIRequest.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

protocol APIRequest {
    associatedtype Response

    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var putData: Data? { get }
    var requestType: APIRequestType { get }

}

extension APIRequest {
    var scheme: String { "https" }
    var host: String { "burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app" }
    var queryItems: [URLQueryItem]? { nil }
    var putData: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        var urlString = ""

        switch requestType {
        case .data:
            print(components.url?.absoluteString)
            urlString = components.url?.absoluteString ?? ""
            print(urlString)
            urlString += ".json"
        case .image:
            urlString = components.url?.absoluteString ?? ""
        }

        var url = URL(string: urlString)!
        print(url)

        var request = URLRequest(url: url)

        return request
    }
}

enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}

enum ImageRequestError: Error {
    case couldNotInitializeFromData
    case imageDataMissing
}

enum APIRequestType {
    case data
    case image
}

extension APIRequest where Response: Decodable {

    func send() async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)
        print(response)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw APIRequestError.itemsNotFound}
        print(data)
        print(String(data: data, encoding: .utf8))

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Response.self, from: data)
        print("this is decoded \(decoded)")

        return decoded
    }
}

extension APIRequest where Response == UIImage {

    func send(url: String) async throws -> UIImage {
//        let (data, response) = try await URLSession.shared.data(for: request)
        guard let url = URL(string: url) else {return UIImage(systemName: "photo")!}
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {throw ImageRequestError.imageDataMissing}
        guard let image = UIImage(data: data) else { throw ImageRequestError.couldNotInitializeFromData}

        return image
    }
}

extension APIRequest {
    func send() async throws -> Void {
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIRequestError.requestFailed}
    }
}
