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
    func makeTrackerHabitScreenView() -> Presentable & TrackerHabitToCoordinatorProtocol
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerSingleEventToCoordinatorProtocol
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
    
    func makeTrackerHabitScreenView() -> Presentable & TrackerHabitToCoordinatorProtocol {
        let vc = TrackerHabitViewController()
        vc.colorModel = ColorModel()
        vc.emojieModel = EmojieModel()
        return vc
    }
    
    func makeTrackerSingleEventScreenView() -> Presentable & TrackerSingleEventToCoordinatorProtocol {
        TrackerSingleEventViewController()
    }
    
    func makeStatisticsScreenView() -> Presentable {
        return StatisticsViewController()
    }
}
