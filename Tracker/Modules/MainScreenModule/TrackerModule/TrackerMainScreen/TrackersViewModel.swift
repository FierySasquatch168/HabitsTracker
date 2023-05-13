//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 09.05.2023.
//

import Foundation

protocol TrackerMainScreenDelegate: AnyObject {
    func saveTracker(tracker: Tracker, to categoryName: String)
}

final class TrackersViewModel {
            
    @Observable
    private (set) var completedTrackers: Set<TrackerRecord> = []
    @Observable
    private (set) var visibleCategories: [TrackerCategory] = [] {
        didSet {
            checkForEmptyState()
        }
    }
    @Observable
    private (set) var emptyStackViewIsHidden: Bool = false
    
    private var dataStore: DataStore
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    func getCurrentDate(from date: Date) -> Date? {
        return date.customlyFormatted()
    }
    
    func filterTrackers(with string: String) {
        var temporaryCategories: [TrackerCategory] = []
        
        for category in visibleCategories {
            let filteredTrackers = category.trackers.filter({ $0.name.lowercased().contains(string.lowercased()) })
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                temporaryCategories.append(filteredCategory)
                visibleCategories = temporaryCategories
            } else {
                visibleCategories = temporaryCategories
            }
        }
    }
}

// MARK: - Ext TrackerMainScreenDelegate
extension TrackersViewModel: TrackerMainScreenDelegate {
    func saveTracker(tracker: Tracker, to categoryName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                try? self.dataStore.saveTracker(tracker: tracker, to: categoryName)
                self.checkForScheduledTrackers(with: getCurrentDate(from: Date()))
            }
        }
    }
}

// MARK: - Ext Collection view checkers
extension TrackersViewModel {
    func checkForEmptyState() {
        emptyStackViewIsHidden = visibleCategories.isEmpty ? false : true
    }
    
    func checkForScheduledTrackers(with currentDate: Date?) {
        // TODO: rewrite to do everything through CoreData
        guard let stringDayOfWeek = currentDate?.weekdayNameStandalone,
              let weekDay = WeekDays.getWeekDay(from: stringDayOfWeek)
        else { return }
        var temporaryCategories: [TrackerCategory] = []
        
        for category in dataStore.fetchCategories() {
            let filteredTrackers = category.trackers.filter({ $0.schedule.contains(weekDay) })
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                temporaryCategories.append(filteredCategory)
                visibleCategories = temporaryCategories
            } else {
                visibleCategories = temporaryCategories
            }
        }
    }
}

// MARK: - Ext Cell properties
extension TrackersViewModel {
    func configureCellProperties(with date: Date?, at indexPath: IndexPath) -> (tracker: Tracker, completed: Bool, count: Int) {
        let tracker = returnTracker(for: indexPath)
        let isCompleted = checkIfTrackerIsCompleted(for: tracker, with: date)
        let cellCount = updateCellCounter(at: indexPath)
        return (tracker, isCompleted, cellCount)
    }
    
    private func returnTracker(for indexPath: IndexPath) -> Tracker {
        return visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    private func checkIfTrackerIsCompleted(for tracker: Tracker, with date: Date?) -> Bool {
        return dataStore.isTrackerCompleted(tracker, with: date) ? true : false
    }

    private func updateCellCounter(at indexPath: IndexPath) -> Int {
        let id = dataStore.fetchCategories()[indexPath.section].trackers[indexPath.row].stringID
        return dataStore.fetchRecords().filter({ $0.id.uuidString == id }).count
    }
}

// MARK: - Ext DataStoreDelegate
extension TrackersViewModel: DataStoreDelegate {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates) {
        visibleCategories = updatedCategories
    }
    
    func didUpdateRecords(_ updatedRecords: Set<TrackerRecord>, _ updates: RecordUpdates) {
        completedTrackers = updatedRecords
    }
}

// MARK: - Ext TrackersListCellDelegate
extension TrackersViewModel {
    func plusTapped(trackerID: String?, currentDate: Date?) {
        guard let trackerID = trackerID, let currentDate = currentDate, currentDate <= Date() else { return }
        
        do {
            try dataStore.updateRecords(trackerID, with: currentDate)
        } catch {
            print("Saving of record failed")
        }
    }
}
