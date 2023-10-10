//
//  HeaderView.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 08.10.2023.
//

import UIKit

final class HeaderView: UICollectionReusableView, ReuseIdentifying {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateCompositionalLayout())
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    let dataSource = ["Burger", "Burger Bowl", "Snack", "Salad", "Steak", "Drink", ""]

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureCollectionView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.collectionView.scrollToItem(at: IndexPath(item: 5, section: 0), at: .right, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: true)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        backgroundColor = .white

        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.register(HeaderCell.self)
    }

    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource
extension HeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HeaderCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.configureCell(text: dataSource[indexPath.item])
        return cell
    }
}
