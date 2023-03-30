//
//  TrackerCollectionSections.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import Foundation

enum TrackerCollectionSections: String, CaseIterable {
    case name = "Название"
    case settings = "Настройки"
    case emojies = "Emojie"
    case colors = "Цвета"
    
    static func getSectionsArray() -> [String] {
        return Self.allCases.map({ $0.rawValue })
    }
}
