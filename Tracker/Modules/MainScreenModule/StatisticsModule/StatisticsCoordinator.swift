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
    
    init(factory: ModulesFactoryProtocol, router: Routable) {
        self.factory = factory
        self.router = router
    }
    
    func start() {
        createScreen()
    }
}

private extension StatisticsCoordinator {
    func createScreen() {
        let trackerMainScreen = factory.makeStatisticsScreenView()
        router.addTabBarItem(trackerMainScreen)
    }
}
