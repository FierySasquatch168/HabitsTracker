//
//  AdditionalSetupEnum.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 04.06.2023.
//

import Foundation

enum AdditionalSetupEnum {
    case schedule([WeekDays]?)
    case category(String?)
    case filters(Filters?)
    
    var headerTitle: String {
        switch self {
        case .schedule:
            return NSLocalizedString(K.LocalizableStringsKeys.schedule, comment: "Schedule")
        case .category:
            return NSLocalizedString(K.LocalizableStringsKeys.category, comment: "Category")
        case .filters:
            return NSLocalizedString(K.LocalizableStringsKeys.filters, comment: "Filters")
        }
    }
    
    var readyButtonTitle: String {
        switch self {
        case .schedule:
            return NSLocalizedString(K.LocalizableStringsKeys.ready, comment: "When the tracker is ready to be saved")
        case .category:
            return NSLocalizedString(K.LocalizableStringsKeys.addCategory, comment: "To add a category")
        case .filters:
            return ""
        }
    }
    
    var readyButtonAppearance: CustomActionButton.Appearance {
        switch self {
        case .schedule(_):
            return .confirm
        case .category(_):
            return .confirm
        case .filters(_):
            return .hidden
        }
    }
}
