//
//  StatisticsCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import Foundation

final class StatisticsCoordinator: MainCoordinator, CoordinatorProtocol {
    
    private var factory: ModulesFactoryProtocol
    private var router: Routable
    private var navigationControllerFactory: NavigationControllerFactoryProtocol
    
    init(factory: ModulesFactoryProtocol, router: Routable, navigationControllerFactory: NavigationControllerFactoryProtocol) {
        self.factory = factory
        self.router = router
        self.navigationControllerFactory = navigationControllerFactory
    }
    
    func start() {
        createScreen()
    }
}

private extension StatisticsCoordinator {
    func createScreen() {
        let statisticsMainScreen = factory.makeStatisticsScreenView()
        let navController = navigationControllerFactory.createNavigationController(.statistics, largeTitle: true, rootViewController: statisticsMainScreen)
        
        router.addTabBarItem(navController)
    }
}
