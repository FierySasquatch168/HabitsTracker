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
        let vc = TrackerCreationViewController()
        vc.mainScreenDelegate = TrackersViewController()
        vc.layoutManager = LayoutManager(headerCreator: HeaderCreator(),
                                         headers: TrackerCollectionSections.getSectionsArray(),
                                         settings: HabitTrackerModel.settings)
        
        vc.dataSourceManager = DataSourceManager(headers: TrackerCollectionSections.getSectionsArray(),
                                                 emojieModel: EmojieModel(),
                                                 colorModel: ColorModel(),
                                                 settings: HabitTrackerModel.settings,
                                                 headerLabeltext: HabitTrackerModel.title)
        return vc
    }
    
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol {
        let vc = TrackerCreationViewController()
        vc.mainScreenDelegate = TrackersViewController()
        vc.layoutManager = LayoutManager(headerCreator: HeaderCreator(),
                                         headers: TrackerCollectionSections.getSectionsArray(),
                                         settings: SingleEventTrackerModel.settings)
        
        vc.dataSourceManager = DataSourceManager(headers: TrackerCollectionSections.getSectionsArray(),
                                                 emojieModel: EmojieModel(),
                                                 colorModel: ColorModel(),
                                                 settings: SingleEventTrackerModel.settings,
                                                 headerLabeltext: SingleEventTrackerModel.title)
        return vc
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
