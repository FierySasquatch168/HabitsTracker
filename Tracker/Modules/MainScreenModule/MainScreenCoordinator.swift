//
//  MainScreenCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import Foundation

final class MainScreenCoordinator: MainCoordinator, CoordinatorProtocol {
    private var factory: CoordinatorFactoryProtocol
    private var router: Routable
    
    init(factory: CoordinatorFactoryProtocol, router: Routable) {
        self.factory = factory
        self.router = router
    }
    
    func start() {
        setupTabBarController()
        createTrackerScreen()
        createStatisticsScreen()
    }
}

private extension MainScreenCoordinator {
    func setupTabBarController() {
        let tabBarController = MainTabBarController()
        router.setupRootViewController(viewController: tabBarController)
    }
    
    func createTrackerScreen() {
        let coordinator = factory.makeTrackerCoordinator(with: router)
        addViewController(coordinator)
        coordinator.start()
    }
    
    func createStatisticsScreen() {
        let coordinator = factory.makeStatisticsCoordinator(with: router)
        addViewController(coordinator)
        coordinator.start()
    }
}
