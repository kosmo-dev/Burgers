//
//  FirebaseSSEClient.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 19.08.2023.
//

import Foundation

final class FirebaseSSEClient: NSObject, URLSessionDataDelegate {
    private var url: URL
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?

    var onReceiveUpdate: ((Int) -> Void)?

    init(url: URL) {
        self.url = url
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    func listenForUpdates() {
        var request = URLRequest(url: url)
        request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
        print("listen for updates")
    }

    func stopListening() {
        dataTask?.cancel()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let messageString = String(data: data, encoding: .utf8), let decodedMessage = decodeSSEMessage(messageString) {
            onReceiveUpdate?(decodedMessage.eventData.data)
        }
    }

    private func decodeSSEMessage(_ message: String) -> FirebaseSSEMessage? {
        let lines = message.split(separator: "\n")

        var event: String?
        var data: String?

        for line in lines {
            let components = line.split(separator: ":", maxSplits: 1)
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)

                if key == "event" {
                    event = value
                } else if key == "data" {
                    data = value
                }
            }
        }

        if let event = event, let data = data {
            let decoder = JSONDecoder()
            if let eventData = try? decoder.decode(FirebaseEvent.self, from: Data(data.utf8)) {
                return FirebaseSSEMessage(event: event, eventData: eventData)
            }
        }

        return nil
    }

}

struct FirebaseEvent: Decodable {
    var path: String
    var data: Int
}

struct FirebaseSSEMessage {
    var event: String
    var eventData: FirebaseEvent
}

