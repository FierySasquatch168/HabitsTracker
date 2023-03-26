//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

// Nice place for DI

protocol ModulesFactoryProtocol {
    func makeSplashScreenView() -> UIViewController
    func makeTrackerScreenView() -> UIViewController
    func makeTrackerSelectionScreenView() -> UIViewController
    func makeStatisticsScreenView() -> UIViewController
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeSplashScreenView() -> UIViewController {
        return SplashViewController()
    }
    
    func makeTrackerScreenView() -> UIViewController {
        return createNavigationController(.trackers, largeTitle: true)
    }
    
    func makeTrackerSelectionScreenView() -> UIViewController {
        return TrackerSelectionViewController()
    }
    
    func makeStatisticsScreenView() -> UIViewController {
        return createNavigationController(.statistics, largeTitle: true)
    }
}

private extension ModulesFactoryProtocol {
    func createNavigationController(_ item: MainTabBarItem, largeTitle: Bool) -> UIViewController {
        let rootViewController = item.viewController
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        navigationController.navigationBar.prefersLargeTitles = largeTitle
        navigationController.tabBarItem.title = item.title
        navigationController.tabBarItem.image = item.tabImage
        
        rootViewController.navigationItem.title = item.title
        
        return navigationController
    }
}
