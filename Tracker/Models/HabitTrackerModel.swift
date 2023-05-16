//
//  HabitTrackerModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 29.03.2023.
//

import Foundation

struct HabitTrackerModel {
    static let title: String = NSLocalizedString(Constants.LocalizableStringsKeys.newHabbit, comment: "New habbit")
    static let settings = [
        NSLocalizedString(Constants.LocalizableStringsKeys.category, comment: "Category"),
        NSLocalizedString(Constants.LocalizableStringsKeys.schedule, comment: "Schedule")
    ]
}
