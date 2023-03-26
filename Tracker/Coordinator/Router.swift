//
//  Router.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

protocol Routable {
    func setupRootViewController(viewController: Presentable)
    func presentViewController(_ viewController: Presentable, animated: Bool, presentationStyle: UIModalPresentationStyle)
    func dismissViewController(_ viewController: Presentable, animated: Bool, completion: (() -> Void)?)
    func addTabBarItem(_ tab: Presentable)
    
}

final class Router {
    weak var delegate: RouterDelegate?
    
    private var currentViewController: Presentable?
    
    init(routerDelegate: RouterDelegate) {
        delegate = routerDelegate
    }
}

extension Router: Routable {
    func setupRootViewController(viewController: Presentable) {
        currentViewController = viewController
        delegate?.setupRootViewController(currentViewController)
    }
    
    func presentViewController(_ viewController: Presentable, animated: Bool, presentationStyle: UIModalPresentationStyle) {
        guard let vc = viewController.toPresent() else {return }
        vc.modalPresentationStyle = presentationStyle
        currentViewController?.toPresent()?.present(vc, animated: true)
        currentViewController = vc
    }
    
    func dismissViewController(_ viewController: Presentable, animated: Bool, completion: (() -> Void)?) {
        self.currentViewController = viewController.toPresent()?.presentingViewController
        viewController.toPresent()?.dismiss(animated: animated, completion: completion)
    }
    
    func addTabBarItem(_ tab: Presentable) {
        guard let vc = tab.toPresent() else { return }
        guard let rootViewController = currentViewController as? UITabBarController else { return }
        var viewControllers = rootViewController.viewControllers ?? []
        viewControllers.append(vc)
        rootViewController.setViewControllers(viewControllers, animated: false)
    }
    
    
}
