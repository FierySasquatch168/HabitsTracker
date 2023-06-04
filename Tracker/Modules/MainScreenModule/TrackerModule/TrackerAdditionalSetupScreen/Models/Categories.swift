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
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesImportant, comment: "Important")
        case .joyfullThings:
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesJoyfullThings, comment: "Joyfull things")
        case .feeling:
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesFeelings, comment: "Feelings")
        case .habits:
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesHabits, comment: "Habits")
        case .attentiveness:
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesAttentiveness, comment: "Attentiveness")
        case .sport:
            return NSLocalizedString(K.LocalizableStringsKeys.categoriesSport, comment: "Sport")
        }
    }
}
