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
    
    var viewController: UIViewController {
        switch self {
        case .trackers:
            return TrackersViewController()
        case .statistics:
            return StatisticsViewController()
        }
    }
    
    var tabImage: UIImage? {
        switch self {
        case .trackers:
            return UIImage(systemName: "record.circle.fill")
        case .statistics:
            return UIImage(systemName: "hare.fill")
        }
    }
    
    var title: String {
        return self.rawValue
    }
}
