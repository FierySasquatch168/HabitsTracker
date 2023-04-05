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
    func makeTrackerHabitScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerCategorieScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeTimeTableScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeStatisticsScreenView() -> Presentable
}

final class ModulesFactory: ModulesFactoryProtocol {
    
    // stable properties
    let trackersViewController = TrackersViewController()
    
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
        return trackersViewController
    }
    
    func makeTrackerSelectionScreenView() -> Presentable & TrackerSelectionCoordinatorProtocol {
        return TrackerSelectionViewController()
    }
    
    func makeTrackerHabitScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = trackersViewController
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: HeaderCreator(), settings: habitSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(emojieModel: EmojieModel(), colorModel: ColorModel(), settings: habitSettings, headerLabeltext: habitLabelText)
        
        return trackerCreationVC
    }
    
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = trackersViewController
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: HeaderCreator(), settings: singleEventSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(emojieModel: EmojieModel(), colorModel: ColorModel(), settings: singleEventSettings, headerLabeltext: singleEventLabeltext)
        
        return trackerCreationVC
    }
    
    func makeTrackerCategorieScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol {
        return TrackerAdditionalSetupViewController()
    }
    
    func makeTimeTableScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol {
        return TrackerAdditionalSetupViewController()
    }
    
    func makeStatisticsScreenView() -> Presentable {
        return StatisticsViewController()
    }
}
