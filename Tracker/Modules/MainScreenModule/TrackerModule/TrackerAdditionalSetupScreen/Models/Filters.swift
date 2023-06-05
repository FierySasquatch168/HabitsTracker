//
//  Filters.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 04.06.2023.
//

import Foundation

enum Filters: CaseIterable {
    case trackersForToday, finished, unfinished
    
    var description: String {
        switch self {
        case .trackersForToday:
            return NSLocalizedString(K.LocalizableStringsKeys.trackersForToday, comment: "trackersForToday")
        case .finished:
            return NSLocalizedString(K.LocalizableStringsKeys.finished, comment: "finished trackers")
        case .unfinished:
            return NSLocalizedString(K.LocalizableStringsKeys.unfinished, comment: "unfinished trackers")
        }
    }
}
