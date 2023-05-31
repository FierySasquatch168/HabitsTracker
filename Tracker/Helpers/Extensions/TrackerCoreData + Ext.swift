//
//  TrackerCoreData + Ext.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 31.05.2023.
//

import Foundation

extension TrackerCoreData {
    func updateWithNewValues(from tracker: Tracker) {
        self.color = UIColorMarshalling.hexString(from: tracker.color)
        self.emojie = tracker.emoji
        self.isPinned = tracker.isPinned
        self.name = tracker.name
        self.schedule = WeekDays.getString(from: tracker.schedule)
    }
}
