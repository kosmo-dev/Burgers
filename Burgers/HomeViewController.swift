//
//  HomeViewController.swift
//  Burgers
//
//  Created by Вадим Кузьмин on 05.10.2022.
//

import UIKit

class HomeViewController: UIViewController {

    let dataSource: [MenuItem] = [
        MenuItem(name: "Black Mamba", description: "What do people think when they hear about us? Of course, about the magnificent \"Black Mamba\". This is a burger that has no equal. An unexpected combination of cherries and marbled beef does not leave indifferent even the most skeptical guests", ingredientsDiscription: "With cherry, bacon and cheddar", price: 530, id: 101, photoURL: "https://burgerheroes.ru/pn/content/products_img/6041e3c391768.png"),
        MenuItem(name: "Special Agent", description: "Eternal classic plays with new colors in our Special Agent. The secret of its taste is in fresh products, self-made sauces and in a steak beef patty. And this superhero saves from hunger with a bang!", ingredientsDiscription: "With cheddar and self-made ketchup", price: 420, id: 102, photoURL: "https://burgerheroes.ru/pn/content/products_img/2.png")
    ]

    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCollectionViewCell else { return UICollectionViewCell() }

        let menuItem = dataSource[indexPath.row]
        cell.configureCell(title: menuItem.name, price: menuItem.price, ingredientsDescription: menuItem.ingredientsDiscription, image: nil)

        return cell
    }


}
