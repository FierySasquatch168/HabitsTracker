//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 02.04.2023.
//

import Foundation

protocol TrackerStorageProtocol {
    var categories: [TrackerCategory] { get set }
    var trackers: [Tracker] { get set }
    var visibleCategories: [TrackerCategory] { get set }
    var completedTrackers: [TrackerRecord] { get set }
    
    func saveTracker(tracker: TrackerCategory)
}

final class TrackerStorage: TrackerStorageProtocol {
    var categories: [TrackerCategory] = []
    var trackers: [Tracker] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    func saveTracker(tracker: TrackerCategory) {
        categories.append(tracker)
    }
}
