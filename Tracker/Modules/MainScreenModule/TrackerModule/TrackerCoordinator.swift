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

private extension TrackerCoordinator {
    func createScreen() {
        var trackerMainScreen = factory.makeTrackerScreenView()
        let navController = navigationControllerFactory.createNavigationController(.trackers, largeTitle: true, rootViewController: trackerMainScreen)
        
        trackerMainScreen.addTrackerButtonPressed = { [weak self] in
            self?.showTrackerSelectionScreen()
        }
        
        router.addTabBarItem(navController)
    }
    
    func showTrackerSelectionScreen() {
        var trackerSelectionScreen = factory.makeTrackerSelectionScreenView()
        trackerSelectionScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerSelectionScreen, animated: true, completion: nil)
            print("TrackerCoordinator showTrackerSelectionScreen returnOnCancel done")
        }
        
        router.presentViewController(trackerSelectionScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showTrackerHabitScreen() {
        
    }
    
    func showHabitSingleEventScreen() {
        
    }
}
