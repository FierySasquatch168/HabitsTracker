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
        
        trackerSelectionScreen.headToHabit = { [weak self] in
            self?.showTrackerHabitScreen()
        }
        
        trackerSelectionScreen.headToSingleEvent = { [weak self] in
            self?.showHabitSingleEventScreen()
        }
        
        router.presentViewController(trackerSelectionScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showTrackerHabitScreen() {
        var trackerHabitScrenn = factory.makeTrackerHabitScreenView()
        trackerHabitScrenn.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerHabitScrenn, animated: true, completion: nil)
            print("TrackerCoordinator showTrackerHabitScreen returnOnCancel done")
        }
        
        trackerHabitScrenn.timeTableTapped = { [weak self] in
            self?.showTrackerTimeTableScreen()
        }
        
        router.presentViewController(trackerHabitScrenn, animated: true, presentationStyle: .pageSheet)
    }
    
    func showHabitSingleEventScreen() {
        var trackerSingleEventScreen = factory.makeTrackerSingleEventScreenView()
        trackerSingleEventScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerSingleEventScreen, animated: true, completion: nil)
            print("TrackerCoordinator showHabitSingleEventScreen returnOnCancel done")
        }
        
        router.presentViewController(trackerSingleEventScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showTrackerTimeTableScreen() {
        var trackerTimetableScreen = factory.makeTimeTableScreenView()
        trackerTimetableScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
            print("TrackerCoordinator showTrackerTimeTableScreen returnOnCancel done")
        }
        
        trackerTimetableScreen.returnOnReady = { [ weak self] in
            // add some property to transfer
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerTimetableScreen, animated: true, presentationStyle: .pageSheet)
    }
}
