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
        vc.colorModel = ColorModel()
        vc.emojieModel = EmojieModel()
        vc.settings = HabitTrackerModel.settings
        vc.headerLabeltext = HabitTrackerModel.title
        return vc
    }
    
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerCreationToCoordinatorProtocol {
        let vc = TrackerCreationViewController()
        vc.colorModel = ColorModel()
        vc.emojieModel = EmojieModel()
        vc.settings = SingleEventTrackerModel.settings
        vc.headerLabeltext = SingleEventTrackerModel.title
        return vc
    }
    
    func makeStatisticsScreenView() -> Presentable {
        return StatisticsViewController()
    }
}
