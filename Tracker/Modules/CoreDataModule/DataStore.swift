//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol DataStoreProtocol {
    var dataStoreTrackersDelegate: DataStoreTrackersDelegate? { get set }
    func fetchCategories() -> [TrackerCategory]
    func fetchRecords() -> Set<TrackerRecord>
    func fetchTrackers() -> [Tracker]
    func saveTracker(tracker: Tracker, to categoryName: String)
    func updateTracker(tracker: Tracker, at categoryName: String)
    func pinTracker(tracker: Tracker, at categoryName: String)
    func updateRecords(_ id: String, with date: Date)
    func isTrackerCompleted(_ tracker: Tracker, with date: Date?) -> Bool
    func deleteTrackers(with id: String, from categoryName: String)
    func getTrackerCategory(for tracker: Tracker) -> String
}

protocol DataStoreStatisticsProviderProtocol {
    func loadDataForStatisticsCheck() -> [TrackerRecordCoreData]
}

protocol DataStoreTrackersDelegate: AnyObject {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates)
    func didUpdateRecords(_ updatedRecords: Set<TrackerRecord>, _ updates: RecordUpdates)
}

protocol DataStoreStatisticsDelegate: AnyObject {
    func didUpdateStatistics(value: Int)
}

protocol TrackerStorageDataStoreDelegate: AnyObject {
    var managedObjectContext: NSManagedObjectContext { get }
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates)
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol, _ updates: RecordUpdates)
}

final class DataStore {
    private let context: NSManagedObjectContext
    
    weak var dataStoreTrackersDelegate: DataStoreTrackersDelegate?
    weak var dataStoreStatisticsDelegate: DataStoreStatisticsDelegate?
        
    var trackerConverter: TrackerConverter?
    var trackerCategoryStore: TrackerCategoryStoreProtocol?
    var trackerRecordStore: TrackerRecordStoreProtocol?
    var trackerStore: TrackerStoreProtocol?
    
    private var fetchedCategories: [TrackerCategory] {
        guard let trackerConverter,
              let fetchedCoreDataTrackers = trackerStore?.fetchCoreDataTrackers()
        else { return [] }
        return trackerCategoryStore?.getViewCategories(with: trackerConverter, from: fetchedCoreDataTrackers) ?? []
    }
    
    private var fetchedRecords: Set<TrackerRecord> {
        guard let trackerConverter else { return [] }
        return trackerRecordStore?.getTrackerRecords(with: trackerConverter) ?? []
    }
    
    private var fetchedTrackers: [Tracker] {
        guard let trackerConverter else { return [] }
        return trackerStore?.fetchTrackers(with: trackerConverter) ?? []
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerConverter = TrackerConverter()
        self.trackerCategoryStore = TrackerCategoryStore(delegate: self)
        self.trackerRecordStore = TrackerRecordStore(delegate: self)
        self.trackerStore = TrackerStore(delegate: self)
    }
}

// MARK: - Ext DataStoreProtocol
extension DataStore: DataStoreProtocol {
    func fetchCategories() -> [TrackerCategory] {
        return fetchedCategories
    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        return fetchedRecords
    }
    
    func fetchTrackers() -> [Tracker] {
        return fetchedTrackers
    }
    
    func isTrackerCompleted(_ tracker: Tracker, with date: Date?) -> Bool {
        return fetchedRecords.filter({ $0.id.uuidString == tracker.stringID && $0.date == date }).isEmpty ? false : true
    }
    
    func saveTracker(tracker: Tracker, to categoryName: String) {
        guard let trackerCoreData = trackerStore?.createTracker(from: tracker) else { return }
        try? trackerCategoryStore?.saveTracker(with: trackerCoreData, to: categoryName)
    }
    
    func updateTracker(tracker: Tracker, at categoryName: String) {
        guard let trackerCoreData = trackerStore?.updateCoreDataTracker(from: tracker) else { return }
        try? trackerCategoryStore?.updateTracker(trackerCoreData: trackerCoreData, at: categoryName)
    }
    
    func pinTracker(tracker: Tracker, at categoryName: String) {
        guard let trackerCoreData = trackerStore?.getCoreDataTracker(from: tracker) else { return }
        try? trackerCategoryStore?.pinTracker(trackerCoreData: trackerCoreData, at: categoryName)
    }
    
    func updateRecords(_ id: String, with date: Date) {
        guard let uuid = UUID(uuidString: id) else { return }
        let record = TrackerRecord(id: uuid, date: date)
        try? trackerRecordStore?.updateStoredRecords(record: record)
    }
    
    func deleteTrackers(with id: String, from categoryName: String) {
        try? trackerCategoryStore?.deleteTracker(with: id, from: categoryName)
        try? trackerRecordStore?.deleteTracker(with: id)
    }
    
    func getTrackerCategory(for tracker: Tracker) -> String {
        return trackerStore?.getCoreDataTracker(from: tracker)?.category?.name ?? "Error"
    }
    
}

// MARK: - Ext DataStoreStatisticsProviderProtocol
extension DataStore: DataStoreStatisticsProviderProtocol {
    func loadDataForStatisticsCheck() -> [TrackerRecordCoreData] {
        let recordsCoreDataArray = trackerRecordStore?.getTrackerRecordsCoreData() ?? []
        return recordsCoreDataArray
    }
}

// MARK: - Ext TrackerStorageDataStoreDelegate
extension DataStore: TrackerStorageDataStoreDelegate {
    var managedObjectContext: NSManagedObjectContext {
        return context
    }
    
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates) {
        guard let trackerConverter,
              let trackersCoreData = trackerStore?.fetchCoreDataTrackers()
        else { return }
        let trackerCategories = store.getViewCategories(with: trackerConverter, from: trackersCoreData)
        dataStoreTrackersDelegate?.didUpdateCategory(trackerCategories, updates)
    }
    
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol, _ updates: RecordUpdates) {
        guard let trackerConverter else { return }
        let trackerRecords = store.getTrackerRecords(with: trackerConverter)
        dataStoreTrackersDelegate?.didUpdateRecords(trackerRecords, updates)
    }
}
