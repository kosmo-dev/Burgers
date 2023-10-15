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
    private var cancellables: Set<AnyCancellable> = []
    private var headerView: HeaderView?

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
        collectionView.delegate = self
        collectionView.register(MenuItemCell.self)
        collectionView.register(NewsItemCell.self)
        collectionView.register(HeaderView.self, kind: "Header")
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
        viewModel.menuDataSourcePublisher.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)

        viewModel.newsDataSourcePublisher.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)

        viewModel.sectionsPublisher.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource
extension MenuViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        switch section {
        case .news:
            return viewModel.news.count
        case .menu:
            return viewModel.menu.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = viewModel.sections[indexPath.section]
        if section == .menu {
            let view: HeaderView = collectionView.dequeueReusableView(indexPath: indexPath, kind: "Header")
            headerView = view
            return view
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.sections[indexPath.section]
        switch section {
        case .news:
            let cell: NewsItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            let news = viewModel.news[indexPath.row]
            
            cell.imageCancellable = viewModel.fetchImage(for: news.photoURL)
                .sink(receiveValue: { image in
                    cell.assignImage(image)
                })
            cell.configureCell(text: news.name)
            return cell
        case .menu:
            let cell: MenuItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            let cellModel = makeMenuCellModel(viewModel.menu[indexPath.row])

            cell.imageCancellable = viewModel.fetchImage(for: cellModel.photoCompressedURL)
                .sink(receiveValue: { image in
                    cell.assignImage(image)
                })
            cell.configureCell(cellModel)
            return cell
        }
    }

    private func makeMenuCellModel(_ menuItem: MenuItem) -> MenuCellModel {
        return MenuCellModel(id: menuItem.id, name: menuItem.name, photoURL: menuItem.photoURL, photoCompressedURL: menuItem.photoCompressedURL, price: menuItem.price, type: menuItem.type, menuItemDescription: menuItem.menuItemDescription)
    }
}

// MARK: - UICollectionViewDelegate
extension MenuViewController: UICollectionViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let headerViewHeight: CGFloat = 40
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.minY + headerViewHeight)
//        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else {return}
//        print(visibleIndexPath)
//        guard visibleIndexPath.section == 1 else { return }
//        let scrollIndexPath = IndexPath(item: visibleIndexPath.item, section: 0)
//        headerView?.collectionView.scrollToItem(at: scrollIndexPath, at: .left, animated: true)
//    }
}

// MARK: - CompositionalLayout
extension MenuViewController {
    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = self?.viewModel.sections[sectionIndex] else { return nil }

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

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "Header", alignment: .top)
                header.pinToVisibleBounds = true

                section.boundarySupplementaryItems = [header]
                return section
            }
        }
        return layout
    }
}
