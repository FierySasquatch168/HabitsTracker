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
            return "Важное"
        case .joyfullThings:
            return "Радостные мелочи"
        case .feeling:
            return "Самочувствие"
        case .habits:
            return "Привычки"
        case .attentiveness:
            return "Внимательность"
        case .sport:
            return "Спорт"
        }
    }
}
