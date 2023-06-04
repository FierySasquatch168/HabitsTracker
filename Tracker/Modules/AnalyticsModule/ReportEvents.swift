//
//  ReportEvents.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import Foundation

enum ReportEvents {
    case open
    case close
    case click
    
    var name: String {
        switch self {
        case .open:
            return "open"
        case .close:
            return "close"
        case .click:
            return "click"
        }
    }
}
