//
//  Categories.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 05.04.2023.
//

import Foundation

enum Categories: String, CaseIterable, CustomStringConvertible {
    case important, joyfullThings, feeling, habits, attentiveness, sport
    
    var description: String {
        switch self {
        case .important:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesImportant, comment: "Important")
        case .joyfullThings:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesJoyfullThings, comment: "Joyfull things")
        case .feeling:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesFeelings, comment: "Feelings")
        case .habits:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesHabits, comment: "Habits")
        case .attentiveness:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesAttentiveness, comment: "Attentiveness")
        case .sport:
            return NSLocalizedString(Constants.LocalizableStringsKeys.categoriesSport, comment: "Sport")
        }
    }
}
