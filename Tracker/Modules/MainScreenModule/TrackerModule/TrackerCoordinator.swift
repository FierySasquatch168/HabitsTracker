//
//  TrackerCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

final class TrackerCoordinator: MainCoordinator, CoordinatorProtocol {
    
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

private extension TrackerCoordinator {
    func createScreen() {
        let trackerMainScreen = factory.makeTrackerScreenView()
        router.addTabBarItem(trackerMainScreen)
    }
}
