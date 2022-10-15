//
//  OrderControllerTests.swift
//  OrderControllerTests
//
//  Created by Вадим Кузьмин on 11.10.2022.
//

import XCTest
@testable import Burgers

final class OrderControllerTests: XCTestCase {
    var sut: OrderController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = OrderController()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testAddAndFetchNewItemInOrder() {
        let givenItem = MenuItem(menuItemDescription: "description", id: 101, ingredientsDescription: "ingredients", name: "Black Mamba", photoURL: "url", photoCompressedURL: "compressedURL", price: 500, type: "burger")

        sut.addToOrder(givenItem)

        let order = sut.order.first!.menuItem

        XCTAssertTrue(order == givenItem)
    }

    func testAddRemoveAndFetchItemInOrder() {
        let givenFirstItem = MenuItem(menuItemDescription: "description", id: 101, ingredientsDescription: "ingredients", name: "Black Mamba", photoURL: "url", photoCompressedURL: "compressedURL", price: 500, type: "burger")
        let givenSecondItem = MenuItem(menuItemDescription: "description2", id: 102, ingredientsDescription: "ingredients2", name: "BadBro", photoURL: "url2", photoCompressedURL: "compressedURL2", price: 400, type: "burger")

        sut.addToOrder(givenFirstItem)
        sut.addToOrder(givenSecondItem)
        sut.removeFromOrder(givenFirstItem)

        let order = sut.order.first!.menuItem

        XCTAssertTrue(order == givenSecondItem)
    }
}
