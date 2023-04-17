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
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol & TrackerMainScreenDelegate
    func makeTrackerSelectionScreenView(with mainScreenDelegate: TrackerMainScreenDelegate?) -> Presentable & TrackerSelectionCoordinatorProtocol & TrackerViceMainScreenDelegate
    func makeTrackerHabitScreenView(with mainScreenDelegate: TrackerViceMainScreenDelegate?) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerSingleEventScreenView(with mainScreenDelegate: TrackerViceMainScreenDelegate?) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol
    func makeTrackerCategorieScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeTimeTableScreenView() -> Presentable & TrackerAdditionalSetupToCoordinatorProtocol
    func makeStatisticsScreenView() -> Presentable
}

final class ModulesFactory: ModulesFactoryProtocol {
    
    /// habit or singleEvent settings
    let habitSettings = HabitTrackerModel.settings
    let singleEventSettings = SingleEventTrackerModel.settings
    /// habit or singleEvent header
    let habitLabelText = HabitTrackerModel.title
    let singleEventLabeltext = SingleEventTrackerModel.title
    
    func makeSplashScreenView() -> Presentable {
        return SplashViewController()
    }
    
    func makeTrackerScreenView() -> Presentable & TrackerToCoordinatorProtocol & TrackerMainScreenDelegate {
        return TrackersViewController()
    }
    
    func makeTrackerSelectionScreenView(with mainScreenDelegate: TrackerMainScreenDelegate?) -> Presentable & TrackerSelectionCoordinatorProtocol & TrackerViceMainScreenDelegate {
        let trackerSelectionVC = TrackerSelectionViewController()
        trackerSelectionVC.mainScreenDelegate = mainScreenDelegate
        return trackerSelectionVC
    }
    
    func makeTrackerHabitScreenView(with mainScreenDelegate: TrackerViceMainScreenDelegate?) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
        trackerCreationVC.layoutManager = LayoutManager(headerCreator: HeaderCreator(), settings: habitSettings)
        trackerCreationVC.dataSourceManager = DataSourceManager(emojieModel: EmojieModel(), colorModel: ColorModel(), settings: habitSettings, headerLabeltext: habitLabelText)
        
        return trackerCreationVC
    }
    
    func makeTrackerSingleEventScreenView(with mainScreenDelegate: TrackerViceMainScreenDelegate?) -> Presentable & TrackerCreationToCoordinatorProtocol & AdditionalTrackerSetupProtocol {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.mainScreenDelegate = mainScreenDelegate
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
