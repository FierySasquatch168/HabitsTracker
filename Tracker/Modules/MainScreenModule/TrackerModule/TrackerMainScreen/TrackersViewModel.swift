//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 09.05.2023.
//

import Foundation

protocol TrackerMainScreenDelegate: AnyObject {
    func saveTracker(tracker: Tracker, to categoryName: String)
    func updateTracker(tracker: Tracker, at categoryName: String)
}

protocol FiltersDelegate: AnyObject {
    var selectedFilter: Filters? { get }
    func transferFilter(from selectedFilter: Filters?)
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
    
    @Observable
    private (set) var selectedTrackerForModifycation: (Tracker?, String?)
    
    var selectedDate: Date?
    
    private var filterSelected: Filters = .all {
        didSet {
            filterVisibleCategoriesBySelectedFilter()
        }
    }
    
    private var dataStore: DataStoreProtocol
    
    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }
    
    func getCurrentDate(from date: Date) -> Date? {
        return date.customlyFormatted()
    }
    
    func filterTrackersBy(_ string: String) {
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
    
    func filterVisibleCategoriesBySelectedFilter() {
        switch selectedFilter {
        case .all:
            checkForScheduledTrackers(for: selectedDate)
        case .trackersForToday:
            // TODO: Менять дату на дэйтпикере
            selectedDate = getCurrentDate(from: Date())
            checkForScheduledTrackers(for: selectedDate)
        case .finished:
            filterTrackersDependingOnCheck(checked: true, for: selectedDate)
        case .unfinished:
            filterTrackersDependingOnCheck(checked: false, for: selectedDate)
        case .none:
            break
        }

        checkForEmptyState()
    }
}

// MARK: - Ext TrackerMainScreenDelegate
extension TrackersViewModel: TrackerMainScreenDelegate {
    func saveTracker(tracker: Tracker, to categoryName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataStore.saveTracker(tracker: tracker, to: categoryName)
            filterVisibleCategoriesBySelectedFilter()
        }
    }
    
    func updateTracker(tracker: Tracker, at categoryName: String) {
        self.dataStore.updateTracker(tracker: tracker, at: categoryName)
        filterVisibleCategoriesBySelectedFilter()
    }
}

// MARK: - Ext ContextMenuOperator
extension TrackersViewModel {
    func pinTapped(at indexPath: IndexPath) {
        let trackerToPinFromCategory = visibleCategories[indexPath.section]
        let trackerToPin = trackerToPinFromCategory.trackers[indexPath.row]
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataStore.pinTracker(tracker: trackerToPin, at: trackerToPinFromCategory.name)
            filterVisibleCategoriesBySelectedFilter()
        }
    }
    
    func modifyTapped(at indexPath: IndexPath) {
        let trackerToModify = visibleCategories[indexPath.section].trackers[indexPath.row]
        let category = dataStore.getTrackerCategory(for: trackerToModify)
        selectedTrackerForModifycation = (trackerToModify, category)
    }
    
    func deleteTapped(at indexPath: IndexPath) {
        let trackerDeletingFromCategory = visibleCategories[indexPath.section]
        let trackerToDelete = trackerDeletingFromCategory.trackers[indexPath.row]
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataStore.deleteTrackers(with: trackerToDelete.stringID ?? "", from: trackerDeletingFromCategory.name)
            filterVisibleCategoriesBySelectedFilter()
        }
    }
}

// MARK: - Ext Collection view checkers
extension TrackersViewModel {
    func checkForEmptyState() {
        emptyStackViewIsHidden = visibleCategories.isEmpty ? false : true
    }
    
    func checkForScheduledTrackers(for date: Date?) {
        let weekDay = getStringDayOfTheWeek(for: selectedDate)
        visibleCategories = getScheduledTrackers(for: weekDay)
    }
    
    func filterTrackersDependingOnCheck(checked: Bool, for date: Date?) {
        let weekDay = getStringDayOfTheWeek(for: selectedDate)
        let filteredCheckedTrackerIds = getRecordsIdsForSelectedDate()
        visibleCategories = getTrackersFilteredBy(checked: checked, for: filteredCheckedTrackerIds, on: weekDay)
        
    }
    
    private func getScheduledTrackers(for weekDay: WeekDays) -> [TrackerCategory] {
        var scheduledCategories: [TrackerCategory] = []
        
        dataStore.fetchCategories().forEach { category in
            let filteredTrackers = category.trackers.filter({ $0.schedule.contains(weekDay) })
            if !filteredTrackers.isEmpty { scheduledCategories.append(TrackerCategory(name: category.name, trackers: filteredTrackers)) }
        }
        
        return scheduledCategories
    }
    
    private func getRecordsIdsForSelectedDate() -> [String] {
        var filteredCheckedTrackerIds: [String] = []
        dataStore.fetchRecords().forEach { record in
            record.date == selectedDate?.customlyFormatted() ? filteredCheckedTrackerIds.append(record.id.uuidString) : ()
        }
        
        return filteredCheckedTrackerIds
    }
    
    private func getTrackersFilteredBy(checked: Bool, for ids: [String], on weekDay: WeekDays) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        dataStore.fetchCategories().forEach { category in
            let filteredTrackers = category
                .trackers
                .filter(
                    { checked ? ids.contains($0.stringID ?? "") : !ids.contains($0.stringID ?? "")
                        && $0.schedule.contains(weekDay)
                    }
                )
            
            if !filteredTrackers.isEmpty { filteredCategories.append(TrackerCategory(name: category.name, trackers: filteredTrackers)) }
        }
        
        return filteredCategories
    }
    
    private func getStringDayOfTheWeek(for date: Date?) -> WeekDays {
        guard let weekDayName = date?.weekdayNameStandalone else { return .saturday }
        return WeekDays.getWeekDay(from: weekDayName) ?? .sunday
    }
}

// MARK: - Ext Cell properties
extension TrackersViewModel {
    func configureCellProperties(with date: Date?, at indexPath: IndexPath) -> (tracker: Tracker, completed: Bool, count: Int) {
        let tracker = returnTracker(for: indexPath)
        let isCompleted = checkIfTrackerIsCompleted(for: tracker, with: date)
        let cellCount = updateCellCounterNew(for: tracker)
        return (tracker, isCompleted, cellCount)
    }
    
    private func returnTracker(for indexPath: IndexPath) -> Tracker {
        return visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    private func checkIfTrackerIsCompleted(for tracker: Tracker, with date: Date?) -> Bool {
        return dataStore.isTrackerCompleted(tracker, with: date) ? true : false
    }
    
    private func updateCellCounterNew(for tracker: Tracker) -> Int {
        let id = dataStore.fetchTrackers().filter({ $0.stringID == tracker.stringID }).first?.stringID
        return dataStore.fetchRecords().filter({ $0.id.uuidString == id }).count
    }
}

// MARK: - Ext DataStoreDelegate
extension TrackersViewModel: DataStoreTrackersDelegate {
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
        dataStore.updateRecords(trackerID, with: currentDate)
    }
}

// MARK: - Ext Filters Delegate
extension TrackersViewModel: FiltersDelegate {
    var selectedFilter: Filters? {
        return filterSelected
    }
    
    func transferFilter(from selectedFilter: Filters?) {
        guard let selectedFilter else { return }
        filterSelected = selectedFilter
    }
}
