//
//  NavigationControllerFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 26.03.2023.
//

import UIKit

protocol NavigationControllerFactoryProtocol {
    func createNavigationController(_ item: MainTabBarItem, largeTitle: Bool, rootViewController: Presentable) -> Presentable
}

final class NavigationControllerFactory: NavigationControllerFactoryProtocol {
    func createNavigationController(_ item: MainTabBarItem, largeTitle: Bool, rootViewController: Presentable) -> Presentable {
        guard let rootVC = rootViewController.toPresent() else { return UIViewController() }
        rootVC.navigationItem.title = item.title
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        navigationController.navigationBar.prefersLargeTitles = largeTitle
        navigationController.tabBarItem.title = item.title
        navigationController.tabBarItem.image = item.tabImage
        
        return navigationController
    }
}
