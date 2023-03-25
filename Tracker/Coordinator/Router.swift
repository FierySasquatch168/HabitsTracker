//
//  Router.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

protocol Routable {
    func setupRootViewController(viewController: UIViewController)
    func addTabBarItem(_ tab: UIViewController)
}

final class Router {
    weak var delegate: RouterDelegate?
    
    private var currentViewController: UIViewController?
    
    init(routerDelegate: RouterDelegate) {
        delegate = routerDelegate
    }
}

extension Router: Routable {
    func setupRootViewController(viewController: UIViewController) {
        currentViewController = viewController
        delegate?.setupRootViewController(currentViewController)
    }
    
    func addTabBarItem(_ tab: UIViewController) {
        guard let rootViewController = currentViewController as? UITabBarController else { return }
        var viewControllers = rootViewController.viewControllers ?? []
        viewControllers.append(tab)
        rootViewController.setViewControllers(viewControllers, animated: false)
    }
    
    
}
