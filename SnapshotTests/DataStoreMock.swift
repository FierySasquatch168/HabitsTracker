//
//  DataStoreMock.swift
//  SnapshotTests
//
//  Created by Aleksandr Eliseev on 02.06.2023.
//

import Foundation
@testable import Tracker

final class DataStoreMock: DataStoreProtocol {
    func fetchCategories() -> [TrackerCategory] {
        return [TrackerCategory(name: "Test", trackers: fetchTrackers())]
    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        var set: Set<TrackerRecord> = []
        let trackerRecord = TrackerRecord(id: UUID(), date: Date())
        set.insert(trackerRecord)
        return set
    }
    
    func fetchTrackers() -> [Tracker] {
        return [Tracker(name: "Test", color: .red, emoji: "🙂", schedule: WeekDays.allCases, stringID: nil, isPinned: false)]
    }
    
    func isTrackerCompleted(_ tracker: Tracker, with date: Date?) -> Bool {
        return false
    }
    
    func getTrackerCategory(for tracker: Tracker) -> String {
        return fetchCategories().first?.name ?? "Test"
    }
    
    func saveTracker(tracker: Tracker, to categoryName: String) {
        
    }
    
    func updateTracker(tracker: Tracker, at categoryName: String) {
        
    }
    
    func pinTracker(tracker: Tracker, at categoryName: String) {
        
    }
    
    func updateRecords(_ id: String, with date: Date) {
        
    }
    
    func deleteTrackers(with id: String, from categoryName: String) {
        
    }
}
