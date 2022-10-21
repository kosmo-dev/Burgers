//
//  ArrayExtension.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 20.10.2022.
//

import Foundation


extension Array where Element: Hashable{
    func makeUniqueElements() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
