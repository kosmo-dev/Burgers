# Burgers 

### Pet project

### Описание проекта

Проект приложения для ресторана-бургерной. Возможность просмотра новостей, меню, описания позиций меню, выбора блюд для заказа и отправки заказа.

![Screenshot](Burgers/Screenshots/screen.gif?raw=true)


### Использованные технологии

- Swift
- UIKit

- Данные меню и новостей доставляются с сервера через REST API спомощью URLSession и Codable

- Используется DiffableDataSource для collectionView

- Многопоточность: async/await для получения данных с сервера

Верстка UI:
- Главные страницы: storyboard + UICollectionViewCompositionalLayout
- Описания позиций меню и новостей: storyboard
- Header View с разделами меню: программная верстка
