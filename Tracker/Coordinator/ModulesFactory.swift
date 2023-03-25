//
//  ModulesFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

protocol ModulesFactoryProtocol {
    func makeSplashScreenView() -> UIViewController
    func makeTrackerScreenView() -> UIViewController
    func makeStatisticsScreenView() -> UIViewController
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeSplashScreenView() -> UIViewController {
        return SplashViewController()
    }
    
    func makeTrackerScreenView() -> UIViewController {
        return TrackersViewController()
    }
    
    func makeStatisticsScreenView() -> UIViewController {
        return StatisticsViewController()
    }
}
