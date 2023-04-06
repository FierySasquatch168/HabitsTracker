//
//  DateFormatter + Ext.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 04.04.2023.
//

import Foundation

extension Date {
    func customlyFormatted() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? Date()
       }
    
    var weekdayNameStandalone: String {
            Formatter.weekdayNameStandalone.string(from: self)
        }
}

extension Formatter {
    static let weekdayNameStandalone: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = .autoupdatingCurrent
            formatter.dateFormat = "EEEEEE"
            return formatter
        }()
}
