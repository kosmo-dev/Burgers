# Burgers 

### Pet project

### Description

Application for a burger restaurant. Features: view news, menu, descriptions of menu items, select dishes to order and send the order.

![Screenshot](Screenshots/screen.gif?raw=true)


### Technology Stack

- Swift
- UIKit

- Data for menus and news get from the server via REST API using URLSession and Codable

- DiffableDataSource for collectionView

- Multithreading: async/await 

UI Layout:
- Main pages: storyboard + UICollectionViewCompositionalLayout
- Descriptions of menu items and news: storyboard
- Header View with menu sections: code layout
