//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 25.03.2023.
//

import UIKit

struct TrackerCategory {
    let name: String // Важное, неважное и т.д.
    let trackers: [Tracker]
}

struct Tracker: Identifiable {
    let id = UUID()
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDays]
    let stringID: String?
}

struct TrackerRecord: Identifiable, Hashable {
    let id: UUID
    let date: Date
}
