//
//  MenuViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.08.2023.
//

import UIKit

class MenuViewController: UIViewController {
    // MARK: - Private Properties
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = S.MenuViewController.title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 37, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateCompositionalLayout())
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let dataSource = ["Black", "Jack", "Steve", "Steak", "Blake", "Lewis", "Clark", "Greek", "Caesar", "Jucie", "Lemonade"]

// MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        configureLayout()
        collectionView.register(MenuItemCell.self)
    }

    // MARK: - Private Methods
    private func configureLayout() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(collectionView)


        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension MenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MenuItemCell = collectionView.dequeReusableCell(indexPath: indexPath)
        cell.configureCell(text: dataSource[indexPath.item])
        return cell
    }
}

// MARK: - CompositionalLayout
extension MenuViewController {
    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
//    let layout1 = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection in
//        let section = self.sections[sectionIndex]
//
//        switch section {
//        case .news:
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/2.5))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//            group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
//
//            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
//
//            return section
//
//        case .menu:
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//            group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
//
//            let section = NSCollectionLayoutSection(group: group)
//
//            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30))
//            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
//            headerItem.pinToVisibleBounds = true
//            headerItem.zIndex = 2
//
//            section.boundarySupplementaryItems = [headerItem]
//
//            return section
//        }
//    }
}
