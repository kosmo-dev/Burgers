//
//  Order.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 11.10.2022.
//

import Foundation

fileprivate let sharedOrderController = OrderController()

protocol OrderControlling {
    var orderController: OrderController {get}
}

extension OrderControlling {
    var orderController: OrderController {
        return sharedOrderController
    }
}

class OrderController {
    private var order: [MenuItem] = []

    func addToOrder(_ item: MenuItem) {
        order.append(item)
    }

    func removeFromOrder(_ item: MenuItem) {
        if let index = order.firstIndex(of: item) {
            order.remove(at: index)
        }
    }

    func fetchOrder() -> [MenuItem] {
        return order
    }
}

/*
 protocol OrderControlling {
  func foo()
 }

 struct OrderController: OrderControlling {
   func foo() {
     // do something
   }
 }

 private struct OrderProviderKey: InjectionKey {
 static var currentValue: OrderControlling = OrderController()
 }

 protocol InjectionKey {
 associatedtype Value

 static var currentValue: Self.Value { get set }
 }

 struct InjectedValues {
 private static var current = InjectedValues()

 /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
 static subscript<K>(key: K.Type) -> K.Value where K : InjectionKey {
 get { key.currentValue }
 set { key.currentValue = newValue }
 }

 /// A static subscript accessor for updating and references dependencies directly.
 static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
 get { current[keyPath: keyPath] }
 set { current[keyPath: keyPath] = newValue }
 }
 }

 extension InjectedValues {
 var orderController: OrderControlling {
 get { Self[OrderProviderKey.self] }
 set { Self[OrderProviderKey.self] = newValue }
 }
 }

 @propertyWrapper
 struct Injected<T> {
 private let keyPath: WritableKeyPath<InjectedValues, T>
 var wrappedValue: T {
 get { InjectedValues[keyPath] }
 set { InjectedValues[keyPath] = newValue }
 }

 init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
 self.keyPath = keyPath
 }
 }
 */
