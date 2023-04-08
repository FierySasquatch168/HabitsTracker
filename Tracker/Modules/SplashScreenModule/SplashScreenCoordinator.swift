//
//  SplashScreenCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

final class SplashScreenCoordinator: MainCoordinator, CoordinatorProtocol {
    private var factory: CoordinatorFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    
    init(factory: CoordinatorFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable) {
        self.factory = factory
        self.modulesFactory = modulesFactory
        self.router = router
    }
    
    func start() {
        showScreen()
    }
}

private extension SplashScreenCoordinator {
    func showScreen() {
        let viewController = modulesFactory.makeSplashScreenView()
        router.setupRootViewController(viewController: viewController)
        createMainScreen()
    }
    
    func createMainScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let coordinator = self.factory.makeMainCoordinator(with: self.router)
            self.addViewController(coordinator)
            coordinator.start()
        }
    }
}
