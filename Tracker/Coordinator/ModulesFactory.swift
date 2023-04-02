//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

// Nice place for DI

protocol ModulesFactoryProtocol {
    func makeSplashScreenView() -> Presentable
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol
    func makeTrackerSelectionScreenView() -> Presentable & TrackerSelectionCoordinatorProtocol
    func makeTrackerHabitScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol
    func makeTrackerCategorieScreenView() -> Presentable & TrackerCategoryToCoordinatorProtocol
    func makeTimeTableScreenView() -> Presentable & TrackerTimeTableToCoordinatorProtocol
    func makeStatisticsScreenView() -> Presentable
}

final class ModulesFactory: ModulesFactoryProtocol {
    
    // stable properties
    let mainScreenDelegate = TrackersViewController()
    let trackerStorage = TrackerStorage()
    let headerCreator = HeaderCreator()
    let headers = TrackerCollectionSections.getSectionsArray()
    let emojieModel = EmojieModel()
    let colorModel = ColorModel()
    
    // properties depending on the user's choise
    /// habit or singleEvent settings
    let habitSettings = HabitTrackerModel.settings
    let singleEventSettings = SingleEventTrackerModel.settings
    /// habit or singleEvent header
    let habitLabelText = HabitTrackerModel.title
    let singleEventLabeltext = SingleEventTrackerModel.title
    
    func makeSplashScreenView() -> Presentable {
        return SplashViewController()
    }
    
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol {
        return TrackersViewController()
    }
    
    func makeTrackerSelectionScreenView() -> Presentable & TrackerSelectionCoordinatorProtocol {
        return TrackerSelectionViewController()
    }
    
    func makeTrackerHabitScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
        trackerCreationVC.trackerStorage = trackerStorage
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: headerCreator, headers: headers, settings: habitSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(headers: headers, emojieModel: emojieModel, colorModel: colorModel, settings: habitSettings, headerLabeltext: habitLabelText)
        
        return trackerCreationVC
    }
    
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
        trackerCreationVC.trackerStorage = trackerStorage
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: headerCreator, headers: headers, settings: singleEventSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(headers: headers, emojieModel: emojieModel, colorModel: colorModel, settings: singleEventSettings, headerLabeltext: singleEventLabeltext)
        
        return trackerCreationVC
    }
    
    func makeTrackerCategorieScreenView() -> Presentable & TrackerCategoryToCoordinatorProtocol {
        return TrackerCategoryScreen()
    }
    
    func makeTimeTableScreenView() -> Presentable & TrackerTimeTableToCoordinatorProtocol {
        return TrackerTimetableScreenViewController()
    }
    
    func makeStatisticsScreenView() -> Presentable {
        return StatisticsViewController()
    }
}
