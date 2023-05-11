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
        
    init() {
        self.fetchTrackers()
        self.fetchRecords()
    }
    
    var coreDataManager: CoreDataManagerProtocol?
    
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
    
    private func fetchTrackers() {
        visibleCategories = coreDataManager?.fetchedCategories ?? []
    }
    
    private func fetchRecords() {
        completedTrackers = coreDataManager?.fetchedRecords ?? []
    }
}

// MARK: - Ext TrackerMainScreenDelegate
extension TrackersViewModel: TrackerMainScreenDelegate {
    func saveTracker(tracker: Tracker, to categoryName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.coreDataManager?.saveTracker(tracker: tracker, to: categoryName)
                self.checkForScheduledTrackers(with: getCurrentDate(from: Date()))
            } catch {
                print("saveTracker failed")
            }
        }
        
    }
}

// MARK: - Ext Collection view checkers
extension TrackersViewModel {
    func checkForEmptyState(){
        emptyStackViewIsHidden = visibleCategories.isEmpty ? false : true
    }
    
    func checkForScheduledTrackers(with currentDate: Date?) {
        // TODO: rewrite to do everything through CoreData
        guard let coreDataManager,
              let stringDayOfWeek = currentDate?.weekdayNameStandalone,
              let weekDay = WeekDays.getWeekDay(from: stringDayOfWeek)
        else { return }
        var temporaryCategories: [TrackerCategory] = []
        
        for category in coreDataManager.fetchedCategories {
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
        guard let coreDataManager else { return false }
        return coreDataManager.trackerCompleted(tracker, with: date) ? true : false
    }

    private func updateCellCounter(at indexPath: IndexPath) -> Int {
        guard let coreDataManager else { return 0 }
        let id = coreDataManager.fetchedCategories[indexPath.section].trackers[indexPath.row].stringID
        return coreDataManager.fetchedRecords.filter({ $0.id.uuidString == id }).count
    }
}

// MARK: - Ext CoreDataManagerDelegate
extension TrackersViewModel: CoreDataManagerDelegate {
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
            try coreDataManager?.updateRecords(trackerID, with: currentDate)
        } catch {
            print("Saving of record failed")
        }
    }
}
