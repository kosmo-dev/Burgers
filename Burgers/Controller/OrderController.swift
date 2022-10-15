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

protocol OrderControllerDelegate {
    func numberOfItemsInOrderChanged(_ count: Int)
}

class OrderController {
    private(set) var order: [OrderItem] = []

    var delegate: OrderControllerDelegate?

    func addToOrder(_ item: MenuItem) {
        if let index = order.firstIndex(where: {$0.menuItem.id == item.id}) {
            order[index].counts += 1
        } else {
            order.append(OrderItem(menuItem: item, counts: 1))
        }
        delegate?.numberOfItemsInOrderChanged(order.count)
    }

    func removeFromOrder(_ item: MenuItem) {
        if let index = order.firstIndex(where: {$0.menuItem.id == item.id}) {
            if order[index].counts > 1 {
                order[index].counts -= 1
            } else {
                order.remove(at: index)
            }
            delegate?.numberOfItemsInOrderChanged(order.count)
        }
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
