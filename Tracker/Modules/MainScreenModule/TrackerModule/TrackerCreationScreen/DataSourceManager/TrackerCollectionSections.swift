//
//  TrackerCollectionSections.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import Foundation

enum TrackerCollectionSections: String, CaseIterable {
    case name
    case settings
    case emojies
    case colors
    
    var name: String {
        switch self {
        case .name:
            return NSLocalizedString(K.LocalizableStringsKeys.name, comment: "Name")
        case .settings:
            return NSLocalizedString(K.LocalizableStringsKeys.settings, comment: "Settings")
        case .emojies:
            return NSLocalizedString(K.LocalizableStringsKeys.emojis, comment: "Emojis")
        case .colors:
            return NSLocalizedString(K.LocalizableStringsKeys.colors, comment: "Colors")
        }
    }
    
    static func getSectionsArray() -> [String] {
        return Self.allCases.map({ $0.name })
    }
}
