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
        let trackerMainScreen = factory.makeTrackerScreenView()
        
        let navController = navigationControllerFactory.createNavigationController(.trackers, largeTitle: true, rootViewController: trackerMainScreen)
        
        trackerMainScreen.addTrackerButtonPressed = { [weak self, weak trackerMainScreen] in
            guard let self, let trackerMainScreen else { return }
            self.showTrackerSelectionScreen(with: trackerMainScreen.viewModel)
        }
        
        trackerMainScreen.modifyTrackerButtonPressed = { [weak self, weak trackerMainScreen] tracker, categoryName in
            guard let self, let trackerMainScreen else { return }
            self.showTrackerHabitScreen(with: trackerMainScreen.viewModel, with: tracker, at: categoryName, isEditing: true)
        }
        
        trackerMainScreen.filterButtonPressed = { [weak self, weak trackerMainScreen] in
            guard let self, let trackerMainScreen else { return }
            self.showFiltersScreen(filtersDelegate: trackerMainScreen.viewModel)
        }
        
        router.addTabBarItem(navController)
    }
    
    // MARK: Tracker Selection
    func showTrackerSelectionScreen(with mainScreenDelegate: TrackerMainScreenDelegate) {
        let trackerSelectionScreen = factory.makeTrackerSelectionScreenView()
        
        trackerSelectionScreen.returnOnCancel = { [weak router, weak trackerSelectionScreen] in
            router?.dismissViewController(trackerSelectionScreen, animated: true, completion: nil)
        }
        
        trackerSelectionScreen.headToHabit = { [weak self, weak mainScreenDelegate] in
            guard let self, let mainScreenDelegate else { return }
            self.showTrackerHabitScreen(with: mainScreenDelegate, with: nil, at: nil, isEditing: false)
        }

        trackerSelectionScreen.headToSingleEvent = { [weak self, weak mainScreenDelegate] in
            guard let self, let mainScreenDelegate else { return }
            self.showHabitSingleEventScreen(with: mainScreenDelegate)
        }
        
        router.presentViewController(trackerSelectionScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: Habit
    
    func showTrackerHabitScreen(with mainScreenDelegate: TrackerMainScreenDelegate, with templateTracker: Tracker?, at templateCategory: String?, isEditing: Bool) {
        var trackerHabitScreen = factory.makeTrackerHabitScreenView(with: mainScreenDelegate)
        trackerHabitScreen.populateTheTemplatesWithSelectedTrackerToModify(with: templateTracker, for: templateCategory)
        trackerHabitScreen.editingTapped = isEditing
        
        trackerHabitScreen.returnOnCancel = { [weak router, weak trackerHabitScreen] in
            router?.dismissViewController(trackerHabitScreen, animated: true, completion: nil)
        }
        
        trackerHabitScreen.categoryTapped = { [weak self, weak trackerHabitScreen] in
            self?.showCategorySelectionScreen(timetableDelegate: trackerHabitScreen)
        }
        
        trackerHabitScreen.scheduleTapped = { [weak self, weak trackerHabitScreen] in
            self?.showTrackerScheduleScreen(scheduleDelegate: trackerHabitScreen)
        }
        
        trackerHabitScreen.saveTrackerTapped = { [weak router] in
            router?.dismissToRootViewController(animated: true, completion: nil)
        }
        
        router.presentViewController(trackerHabitScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: SingleEvent
    
    func showHabitSingleEventScreen(with mainScreenDelegate: TrackerMainScreenDelegate) {
        var trackerSingleEventScreen = factory.makeTrackerSingleEventScreenView(with: mainScreenDelegate)
        
        trackerSingleEventScreen.returnOnCancel = { [weak router, weak trackerSingleEventScreen] in
            router?.dismissViewController(trackerSingleEventScreen, animated: true, completion: nil)
        }
        
        trackerSingleEventScreen.categoryTapped = { [weak self, weak trackerSingleEventScreen] in
            self?.showCategorySelectionScreen(timetableDelegate: trackerSingleEventScreen)
        }
        
        trackerSingleEventScreen.saveTrackerTapped = { [weak router] in
            router?.dismissToRootViewController(animated: true, completion: nil)
        }
        
        router.presentViewController(trackerSingleEventScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: Category selection
    
    func showCategorySelectionScreen(timetableDelegate: AdditionalTrackerSetupProtocol?) {
        let trackerCategoryScreen = factory.makeTrackerCategorieScreenView(timetableDelegate: timetableDelegate)
        
        trackerCategoryScreen.returnOnCancel = { [weak router, weak trackerCategoryScreen] in
            router?.dismissViewController(trackerCategoryScreen, animated: true, completion: nil)
        }
        
        trackerCategoryScreen.returnOnCategoryReady = { [weak router, weak trackerCategoryScreen] category in
            trackerCategoryScreen?.additionalTrackerSetupDelegate?.transferCategory(from: category)
            router?.dismissViewController(trackerCategoryScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerCategoryScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: TimeTable
    
    func showTrackerScheduleScreen(scheduleDelegate: AdditionalTrackerSetupProtocol?) {
        let trackerTimetableScreen = factory.makeTimeTableScreenView(timetableDelegate: scheduleDelegate)
        
        trackerTimetableScreen.returnOnCancel = { [weak router, weak trackerTimetableScreen] in
            router?.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        trackerTimetableScreen.returnOnTimetableReady = { [weak router, weak trackerTimetableScreen] days in
            trackerTimetableScreen?.additionalTrackerSetupDelegate?.transferSchedule(from: days)
            router?.dismissViewController(trackerTimetableScreen, animated: true, completion: nil)
        }
        
        router.presentViewController(trackerTimetableScreen, animated: true, presentationStyle: .pageSheet)
    }
    
    // MARK: Filters
    func showFiltersScreen(filtersDelegate: FiltersDelegate?) {
        let filterScreenView = factory.makeFiltersScreenView(filtersDelegate: filtersDelegate)
        
        filterScreenView.returnOnCancel = { [weak router, weak filterScreenView] in
            router?.dismissViewController(filterScreenView, animated: true, completion: nil)
        }
        
        filterScreenView.returnOnFiltersReady = { [weak router, weak filterScreenView] filter in
            filterScreenView?.filterSetupDelegate?.transferFilter(from: filter)
            router?.dismissViewController(filterScreenView, animated: true, completion: nil)
        }
        
        router.presentViewController(filterScreenView, animated: true, presentationStyle: .pageSheet)
        
    }
}
