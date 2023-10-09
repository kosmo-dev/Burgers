//
//  CellReusingUtils.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 24.08.2023.
//

import UIKit

protocol ReuseIdentifying {
    static var defaultReuseIdentifier: String { get }
}

extension ReuseIdentifying where Self: UITableViewCell {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

extension ReuseIdentifying where Self: UICollectionViewCell {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

extension ReuseIdentifying where Self: UICollectionReusableView {
    static var defaultReuseIdentifier: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? NSStringFromClass(self)
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ : T.Type) where T: ReuseIdentifying {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: ReuseIdentifying {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            assertionFailure("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier) for: \(indexPath)")
            return T()
        }
        return cell
    }

    func register<T: UICollectionReusableView>(_ : T.Type, kind: String) where T: ReuseIdentifying {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableView<T: UICollectionReusableView>(indexPath: IndexPath, kind: String) -> T where T: ReuseIdentifying {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            assertionFailure("Could not dequeue view with identifier: \(T.defaultReuseIdentifier) for: \(indexPath)")
            return T()
        }
        return view
    }
}