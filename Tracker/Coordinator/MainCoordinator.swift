//
//  MainCoordinator.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    func start()
}

class MainCoordinator {
    var childCoordinators: [CoordinatorProtocol] = []
    
    func addViewController(_ coordinator: CoordinatorProtocol) {
        childCoordinators.forEach { childCoordinator in
            if childCoordinator === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeViewController(_ coordinator: CoordinatorProtocol?) {
        guard let coordinator = coordinator else { return }
        childCoordinators.removeAll { childCoordinator in
            childCoordinator === coordinator
        }
    }
}
