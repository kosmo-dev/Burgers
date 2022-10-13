//
//  BurgersAPITests.swift
//  BurgersAPITests
//
//  Created by Вадим Кузьмин on 11.10.2022.
//

import XCTest
@testable import Burgers

final class BurgersAPITests: XCTestCase {

    var sut: URLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testValidAPICallGetHTTPSStatusCode200() {
        let urlString = "https://burgers-ae4c1-default-rtdb.europe-west1.firebasedatabase.app"

        let promise = expectation(description: "Status code: 200")

        Task {
            do {
                let (_, response) = try await sut.data(from: URL(string: urlString)!)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        promise.fulfill()
                    } else {
                        XCTFail("Status code: \(httpResponse.statusCode)")
                    }
                }
            } catch {
                XCTFail("Error \(error.localizedDescription)")
            }
        }
        wait(for: [promise], timeout: 5)
    }
}
