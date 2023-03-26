//
//  MainTabBarItem.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

enum MainTabBarItem: String {
    case trackers = "Трекеры"
    case statistics = "Статистика"
    
    var tabImage: UIImage? {
        switch self {
        case .trackers:
            return UIImage(systemName: Constants.Icons.trackersTabIcon)
        case .statistics:
            return UIImage(systemName: Constants.Icons.statisticsTabIcon)
        }
    }
    
    var title: String {
        return self.rawValue
    }
}
