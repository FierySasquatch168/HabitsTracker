//
//  MainTabBarItem.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

enum MainTabBarItem: String {
    case trackers
    case statistics
    
    var tabImage: UIImage? {
        switch self {
        case .trackers:
            return UIImage(systemName: Constants.Icons.trackersTabIcon)
        case .statistics:
            return UIImage(systemName: Constants.Icons.statisticsTabIcon)
        }
    }
    
    var title: String {
        switch self {
        case .trackers:
            return NSLocalizedString(Constants.LocalizableStringsKeys.tabBarTitletrackers, comment: "Tracker title")
        case .statistics:
            return NSLocalizedString(Constants.LocalizableStringsKeys.tabBarTitlestatistics, comment: "Statistics title")
        }
    }
}
