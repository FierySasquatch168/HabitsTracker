//
//  CoordinatorFactory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

protocol CoordinatorFactoryProtocol {
    func makeSplashCoordinator(with router: Routable) -> CoordinatorProtocol
    func makeMainCoordinator(with router: Routable) -> CoordinatorProtocol
    func makeTrackerCoordinator(with router: Routable) -> CoordinatorProtocol
    func makeStatisticsCoordinator(with router: Routable) -> CoordinatorProtocol
}

final class CoordinatorFactory  {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

extension CoordinatorFactory: CoordinatorFactoryProtocol {
    func makeSplashCoordinator(with router: Routable) -> CoordinatorProtocol {
        SplashScreenCoordinator(factory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeMainCoordinator(with router: Routable) -> CoordinatorProtocol {
        MainScreenCoordinator(factory: self, router: router)
    }
    
    func makeTrackerCoordinator(with router: Routable) -> CoordinatorProtocol {
        TrackerCoordinator(factory: modulesFactory, router: router)
    }
    
    func makeStatisticsCoordinator(with router: Routable) -> CoordinatorProtocol {
        StatisticsCoordinator(factory: modulesFactory, router: router)
    }
}
