//
//  MenuViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 23.08.2023.
//

import UIKit
import Combine

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

    private var viewModel: MenuViewModelProtocol

    private var menuDataSourceSubscriber: AnyCancellable?
    private var newsDataSourceSubscriber: AnyCancellable?
    private var sectionsSubscriber: AnyCancellable?

    private var menuDataSource: [MenuItem] = []
    private var newsDataSource: [NewsItem] = []
    private var sections: [MenuViewModel.Section] = []

    // MARK: - Initializers
    init(viewModel: MenuViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureLayout()
        setSubscriptions()
        viewModel.viewDidLoad()
    }

    // MARK: - Private Methods
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.register(MenuItemCell.self)
        collectionView.register(NewsItemCell.self)
    }

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

    private func setSubscriptions() {
        menuDataSourceSubscriber = viewModel.menuDataSourcePublisher.sink { [weak self] menu in
            self?.menuDataSource = menu
            self?.collectionView.reloadData()
        }

        newsDataSourceSubscriber = viewModel.newsDataSourcePublisher.sink { [weak self] news in
            self?.newsDataSource = news
            self?.collectionView.reloadData()
        }

        sectionsSubscriber = viewModel.sectionsPublisher.sink { [weak self] sections in
            self?.sections = sections
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MenuViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections[section]
        switch section {
        case .news:
            return newsDataSource.count
        case .menu:
            return menuDataSource.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        switch section {
        case .news:
            let cell: NewsItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.configureCell(text: newsDataSource[indexPath.item].name)
            return cell
        case .menu:
            let cell: MenuItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.configureCell(text: menuDataSource[indexPath.row].name)
            return cell
        }
    }
}

// MARK: - CompositionalLayout
extension MenuViewController {
    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = self?.sections[sectionIndex] else { return nil }

            switch section {
            case .news:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/2.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

                return section
            case .menu:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        return layout
    }
}
