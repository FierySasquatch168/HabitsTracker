//
//  TrackerCreationVCSpy.swift
//  SnapshotTests
//
//  Created by Aleksandr Eliseev on 02.06.2023.
//

import UIKit
@testable import Tracker


final class TrackerCreationVCSpy: TrackerCreationTestable {
    var trackerMainScreenDelegate: TrackerMainScreenDelegate?
    
    func saveTracker() {
        let tracker = createTracker(name: "Test", color: .red, emoji: "🙂", schedule: WeekDays.allCases)
        trackerMainScreenDelegate?.saveTracker(tracker: tracker, to: "TestCase")
    }
    
    func createTracker(name: String, color: UIColor, emoji: String, schedule: [WeekDays]) -> Tracker {
        return Tracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            stringID: nil,
            isPinned: false
        )
    }
}
