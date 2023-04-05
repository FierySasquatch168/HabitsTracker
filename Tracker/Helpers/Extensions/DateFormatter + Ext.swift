//
//  DateFormatter + Ext.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 04.04.2023.
//

import Foundation

extension Date {
    func toString(format: String = "dd MMMM yyyy") -> String {
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.dateFormat = format
           return formatter.string(from: self)
       }
}
