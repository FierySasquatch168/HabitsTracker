//
//  DataStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol DataStoreProtocol {
    func fetchCategories() -> [TrackerCategory]
    func fetchRecords() -> Set<TrackerRecord>
    func fetchTrackers() -> [Tracker]
    func saveTracker(tracker: Tracker, to categoryName: String) throws
    func updateTracker(tracker: Tracker, at categoryName: String) throws
    func updateRecords(_ id: String, with date: Date) throws
    func isTrackerCompleted(_ tracker: Tracker, with date: Date?) -> Bool
    func deleteTrackers(with id: String, from categoryName: String)
}

protocol DataStoreDelegate: AnyObject {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates)
    func didUpdateRecords(_ updatedRecords: Set<TrackerRecord>, _ updates: RecordUpdates)
}

protocol TrackerStorageDataStoreDelegate: AnyObject {
    var managedObjectContext: NSManagedObjectContext { get }
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates)
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol, _ updates: RecordUpdates)
}

final class DataStore {
    private let context: NSManagedObjectContext
    
    weak var dataStoreDelegate: DataStoreDelegate?
    
    var trackerConverter: TrackerConverter?
    var trackerCategoryStore: TrackerCategoryStoreProtocol?
    var trackerRecordStore: TrackerRecordStoreProtocol?
    var trackerStore: TrackerStoreProtocol?
    
    private var fetchedCategories: [TrackerCategory] {
        guard let trackerConverter else { return [] }
        return trackerCategoryStore?.getCategories(with: trackerConverter) ?? []
    }
    
    private var fetchedRecords: Set<TrackerRecord> {
        guard let trackerConverter else { return [] }
        return trackerRecordStore?.getTrackerRecords(with: trackerConverter) ?? []
    }
    
    private var fetchedTrackers: [Tracker] {
        guard let trackerConverter else { return [] }
        return trackerStore?.fetchTrackers(with: trackerConverter) ?? []
    }
    
    private let persistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    init() {
        self.context = persistentContainer.newBackgroundContext()
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
    
    func isTrackerCompleted(_ tracker: Tracker,
                          with date: Date?) -> Bool {
        return fetchedRecords.filter({ $0.id.uuidString == tracker.stringID && $0.date == date }).isEmpty ? false : true
    }
    
    func saveTracker(tracker: Tracker,
                     to categoryName: String) throws {
        guard let trackerCoreData = trackerStore?.makeTracker(from: tracker, with: context)
        else { return }
        
        do {
            try trackerCategoryStore?.saveTracker(with: trackerCoreData, to: categoryName)
        } catch {
            throw CoreDataError.failedToSaveContext
        }
    }
    
    func updateTracker(tracker: Tracker, at categoryName: String) throws {
        do {
            try trackerCategoryStore?.updateTracker(tracker: tracker, at: categoryName)
        } catch {
            throw CoreDataError.failedToUpdateTracker
        }
    }
    
    func updateRecords(_ id: String, with date: Date) throws {
        guard let uuid = UUID(uuidString: id) else { return }
        do {
            let record = TrackerRecord(id: uuid, date: date)
            try trackerRecordStore?.updateStoredRecords(record: record)
        } catch {
            throw CoreDataError.failedToManageRecords
        }
    }
    
    func deleteTrackers(with id: String, from categoryName: String) {
        try? trackerCategoryStore?.deleteTracker(with: id, from: categoryName)
    }
    
    
}

// MARK: - Ext TrackerStorageDataStoreDelegate
extension DataStore: TrackerStorageDataStoreDelegate {
    var managedObjectContext: NSManagedObjectContext {
        return context
    }
    
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol,
                           _ updates: CategoryUpdates) {
        guard let trackerConverter,
              let trackerCategories = trackerCategoryStore?.getCategories(with: trackerConverter) else { return }
        dataStoreDelegate?.didUpdateCategory(trackerCategories, updates)
    }
    
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol,
                         _ updates: RecordUpdates) {
        guard let trackerConverter,
              let trackerRecords = trackerRecordStore?.getTrackerRecords(with: trackerConverter) else { return }
        dataStoreDelegate?.didUpdateRecords(trackerRecords, updates)
    }
}
