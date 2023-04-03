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

// MARK: - Ext ScreensCreation
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
        var trackerHabitScreen = factory.makeTrackerHabitScreenView()
        trackerHabitScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerHabitScreen, animated: true, completion: nil)
            print("TrackerCoordinator showTrackerHabitScreen returnOnCancel done")
        }
        
        trackerHabitScreen.categoryTapped = { [weak self] in
            self?.showCategorySelectionScreen()
        }
        
        trackerHabitScreen.timeTableTapped = { [weak self] in
            // TODO: think about a better way of setting the delegate
            self?.showTrackerTimeTableScreen(timetableDelegate: trackerHabitScreen)
        }
        
        trackerHabitScreen.saveTrackerTapped = { [weak self] in
            self?.router.dismissToRootViewController(animated: true, completion: nil)
        }
        
        router.presentViewController(trackerHabitScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showHabitSingleEventScreen() {
        var trackerSingleEventScreen = factory.makeTrackerSingleEventScreenView()
        trackerSingleEventScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerSingleEventScreen, animated: true, completion: nil)
            print("TrackerCoordinator showHabitSingleEventScreen returnOnCancel done")
        }
        
        trackerSingleEventScreen.categoryTapped = { [weak self] in
            self?.showCategorySelectionScreen()
        }
        
        router.presentViewController(trackerSingleEventScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showCategorySelectionScreen() {
        var trackerCategorieScreen = factory.makeTrackerCategorieScreenView()
        trackerCategorieScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerCategorieScreen, animated: true, completion: nil)
            print("TrackerCoordinator showCategorySelectionScreen returnOnCancel done")
        }
        
        router.presentViewController(trackerCategorieScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    func showTrackerTimeTableScreen(timetableDelegate: TimetableTransferDelegate) {
        var trackerTimetableScreen = factory.makeTimeTableScreenView()
        trackerTimetableScreen.timetableTransferDelegate = timetableDelegate
        trackerTimetableScreen.returnOnCancel = { [weak self] in
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
            print("TrackerCoordinator showTrackerTimeTableScreen returnOnCancel done")
        }
        
        trackerTimetableScreen.returnOnReady = { [ weak self] days in
            // add some property to transfer
            trackerTimetableScreen.timetableTransferDelegate?.transferTimeTable(from: days)
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerTimetableScreen, animated: true, presentationStyle: .pageSheet)
    }
}
