//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 24.03.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

extension MainTabBarController {
    func configure() {
        setTabBarAppearance()
    }
    
    private func setTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        setTabBarItemColors(tabBarAppearance.stackedLayoutAppearance)
        setTabBarItemColors(tabBarAppearance.inlineLayoutAppearance)
        
        tabBarAppearance.backgroundColor = .YPWhite
        tabBar.standardAppearance = tabBarAppearance
        tabBar.tintColor = .YPWhite
    }
    
    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.iconColor = .YPGray
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.YPGray ?? .gray]
        
        itemAppearance.selected.iconColor = .YPBlue
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.YPBlue ?? .blue]
    }
}
