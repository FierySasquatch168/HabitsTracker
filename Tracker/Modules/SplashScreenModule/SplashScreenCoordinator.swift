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
        createMainFlow()
    }
    
    func createMainFlow() {
        let isFirstLaunch = FirstEnterChecker.firstEntrance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            isFirstLaunch ? self.createOnboardingScreen() : self.createMainScreen()
        }
    }
    
    func createOnboardingScreen() {
        var onboardingScreen = modulesFactory.makeOnboardingScreenView()
        
        onboardingScreen.onFinish = { [weak self] in
            self?.createMainScreen()
        }
        
        router.presentViewController(onboardingScreen, animated: true, presentationStyle: .fullScreen)
    }
    
    func createMainScreen() {
        let coordinator = factory.makeMainCoordinator(with: router)
        addViewController(coordinator)
        coordinator.start()
    }
}
