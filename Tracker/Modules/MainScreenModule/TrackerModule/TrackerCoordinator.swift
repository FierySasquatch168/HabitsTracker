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
            self?.showTrackerSelectionScreen(with: trackerMainScreen)
        }
        
        router.addTabBarItem(navController)
    }
    
    // MARK: Tracker Selection
    func showTrackerSelectionScreen(with mainScreenDelegate: TrackerMainScreenDelegate?) {
        var trackerSelectionScreen = factory.makeTrackerSelectionScreenView(with: mainScreenDelegate)
        
        trackerSelectionScreen.returnOnCancel = { [weak self, weak trackerSelectionScreen] in
            self?.router.dismissViewController(trackerSelectionScreen, animated: true, completion: nil)
        }
        
        trackerSelectionScreen.headToHabit = { [weak self, weak trackerSelectionScreen] in
            self?.showTrackerHabitScreen(with: trackerSelectionScreen)
        }

        trackerSelectionScreen.headToSingleEvent = { [weak self] in
            self?.showHabitSingleEventScreen()
        }
        
        router.presentViewController(trackerSelectionScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: Habit
    
    func showTrackerHabitScreen(with mainScreenDelegate: TrackerViceMainScreenDelegate?) {
        var trackerHabitScreen = factory.makeTrackerHabitScreenView(with: mainScreenDelegate)
        
        trackerHabitScreen.returnOnCancel = { [weak self, weak trackerHabitScreen] in
            self?.router.dismissViewController(trackerHabitScreen, animated: true, completion: nil)
        }
        
        trackerHabitScreen.categoryTapped = { [weak self, weak trackerHabitScreen] in
            self?.showCategorySelectionScreen(timetableDelegate: trackerHabitScreen)
        }
        
        trackerHabitScreen.timeTableTapped = { [weak self, weak trackerHabitScreen] in
            // TODO: think about a better way of setting the delegate
            self?.showTrackerTimeTableScreen(timetableDelegate: trackerHabitScreen)
        }
        
        trackerHabitScreen.saveTrackerTapped = { [weak self] in
            self?.router.dismissToRootViewController(animated: true, completion: nil)
        }
        
        router.presentViewController(trackerHabitScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: SingleEvent
    
    func showHabitSingleEventScreen() {
        var trackerSingleEventScreen = factory.makeTrackerSingleEventScreenView()
        trackerSingleEventScreen.returnOnCancel = { [weak self, weak trackerSingleEventScreen] in
            self?.router.dismissViewController(trackerSingleEventScreen, animated: true, completion: nil)
        }
        
        trackerSingleEventScreen.categoryTapped = { [weak self, weak trackerSingleEventScreen] in
            self?.showCategorySelectionScreen(timetableDelegate: trackerSingleEventScreen)
        }
        
        trackerSingleEventScreen.saveTrackerTapped = { [weak self] in
            self?.router.dismissToRootViewController(animated: true, completion: nil)
        }
        
        router.presentViewController(trackerSingleEventScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: Category selection
    
    func showCategorySelectionScreen(timetableDelegate: AdditionalTrackerSetupProtocol?) {
        let trackerCategoryScreen = factory.makeTrackerCategorieScreenView()
        
        trackerCategoryScreen.timetableSelected = false
        
        trackerCategoryScreen.additionalTrackerSetupDelegate = timetableDelegate
        
        trackerCategoryScreen.returnOnCancel = { [weak self, weak trackerCategoryScreen] in
            self?.router.dismissViewController(trackerCategoryScreen, animated: true, completion: nil)
        }
        
        trackerCategoryScreen.returnOnCategoryReady = { [weak self, weak trackerCategoryScreen] category in
            trackerCategoryScreen?.additionalTrackerSetupDelegate?.transferCategory(from: category)
            self?.router.dismissViewController(trackerCategoryScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerCategoryScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: TimeTable
    
    func showTrackerTimeTableScreen(timetableDelegate: AdditionalTrackerSetupProtocol?) {
        let trackerTimetableScreen = factory.makeTimeTableScreenView()
        
        trackerTimetableScreen.timetableSelected = true
        
        trackerTimetableScreen.additionalTrackerSetupDelegate = timetableDelegate
        
        trackerTimetableScreen.returnOnCancel = { [weak self, weak trackerTimetableScreen] in
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        trackerTimetableScreen.returnOnTimetableReady = { [weak self, weak trackerTimetableScreen] days in
            // add some property to transfer
            trackerTimetableScreen?.additionalTrackerSetupDelegate?.transferTimeTable(from: days)
            self?.router.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerTimetableScreen, animated: true, presentationStyle: .pageSheet)
    }
}
