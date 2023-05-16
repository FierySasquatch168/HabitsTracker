//
//  Sections.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.04.2023.
//

import Foundation

enum Sections: String, CaseIterable {
    case trackerName
    case trackerSettings
    case emojies
    case colors
    
    var name: String {
        switch self {
        case .trackerName:
            return ""
        case .trackerSettings:
            return ""
        case .emojies:
            return NSLocalizedString(Constants.LocalizableStringsKeys.emojis, comment: "Emojies")
        case .colors:
            return NSLocalizedString(Constants.LocalizableStringsKeys.colors, comment: "Colors")
        }
    }
}
