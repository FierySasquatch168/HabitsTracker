//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    var fetchedCategories: [TrackerCategory] { get }
    var fetchedRecords: Set<TrackerRecord> { get }
    func fetchTrackerCategories() throws -> [TrackerCategory]
    func saveTracker(tracker: Tracker, to categoryName: String) throws
    func updateRecords(_ id: String, with date: Date) throws
}

protocol CoreDataManagerDelegate: AnyObject {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates)
    func didUpdateRecords(_ updatedRecords: Set<TrackerRecord>, _ updates: RecordUpdates)
}

protocol TrackerStorageCoreDataDelegate: AnyObject {
    var managedObjectContext: NSManagedObjectContext { get }
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates)
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol, _ updates: RecordUpdates)
} 

final class CoreDataManager {
    private let context: NSManagedObjectContext
    
    weak var coreDataManagerDelegate: CoreDataManagerDelegate?
    
    private var trackerCategoryStore: TrackerCategoryStoreProtocol?
    private var trackerRecordStore: TrackerRecordStoreProtocol?
    private var trackerStore: TrackerStoreProtocol?
    
    //TODO: Move to TrackerCategoryStore
    var fetchedCategories: [TrackerCategory] {
        guard let objects = trackerCategoryStore?.trackerFetchedResultsController.fetchedObjects,
              let categories = try? objects.compactMap({ try getCategory(from: $0) })
        else {
            return []
        }
        return categories
    }
    
    var fetchedRecords: Set<TrackerRecord> {
        guard let objects = trackerRecordStore?.getTrackerRecords() else { return [] }
        return objects
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
    
    init(coreDataManagerDelegate: CoreDataManagerDelegate) {
        self.context = persistentContainer.newBackgroundContext()
        self.coreDataManagerDelegate = coreDataManagerDelegate
        self.trackerStore = TrackerStore(delegate: self)
        self.trackerCategoryStore = TrackerCategoryStore(delegate: self)
        self.trackerRecordStore = TrackerRecordStore(delegate: self)
    }
    
    // TODO: move to trackerCategoryStore
    private func getCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = categoryCoreData.name,
              let coreDataTrackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData],
              let trackers = try? coreDataTrackers.compactMap({ try trackerStore?.getTracker(from: $0) })
        else {
            throw StoreError.decodingErrorInvalidCategoryData
        }
        
        return TrackerCategory(name: name, trackers: trackers)
    }
}

// MARK: - Ext CoreDataManagerProtocol
extension CoreDataManager: CoreDataManagerProtocol {
    //TODO: Delete fetchTrackerCategories and reorganize fetch to "fetchedCategories"
    func fetchTrackerCategories() throws -> [TrackerCategory] {
        guard let categoriesCoreData = trackerCategoryStore?.trackerFetchedResultsController.fetchedObjects,
              let trackersCoreData = trackerStore?.trackerFetchedResultsController.fetchedObjects
        else {
            return []
        }
        
        var trackerCategories: [TrackerCategory] = []
        
        categoriesCoreData.forEach { trackerCategoryCoreData in
            let filteredCoreDataTrackers = trackersCoreData.filter({ $0.category?.name == trackerCategoryCoreData.name })
            let trackerToView = try? filteredCoreDataTrackers.compactMap({ try trackerStore?.getTracker(from: $0) })
            let category = TrackerCategory(name: trackerCategoryCoreData.name ?? "", trackers: trackerToView ?? [])
            trackerCategories.append(category)
        }
        
        return trackerCategories
    }
   
    func saveTracker(tracker: Tracker, to categoryName: String) throws {
        guard let trackerCoreData = trackerStore?.makeTracker(from: tracker)
        else {
            return
        }
        
        // загрузить действующую категорию с таким именем
        if let existingCategory = try? trackerCategoryStore?.fetchCategory(with: categoryName),
           var newCoreDataTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] {
            // если она есть, поменять у нее свойство трэкерс и загрузить обратно
            newCoreDataTrackers.append(trackerCoreData)
            existingCategory.trackers = NSSet(array: newCoreDataTrackers)
        } else {
            // если ее нет, создать новую
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = categoryName
            newCategory.trackers = NSSet(array: [trackerCoreData])
        }
        
        do {
            try context.save()
        } catch {
            throw StoreError.failedToSaveContext
        }
    }
    
    func updateRecords(_ id: String, with date: Date) throws {
        guard let uuid = UUID(uuidString: id) else { return }
        do {
            let record = TrackerRecord(id: uuid, date: date)
            try trackerRecordStore?.updateRecordsCoreData(record: record)
        } catch {
            throw StoreError.failedToManageRecords
        }
    }
    
    
}

// MARK: - Ext TrackerStorageCoreDataDelegate
extension CoreDataManager: TrackerStorageCoreDataDelegate {
    var managedObjectContext: NSManagedObjectContext {
        return context
    }
    
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates) {
        guard let fetchedCoreDataCategories = store.trackerFetchedResultsController.fetchedObjects,
              let trackerCategories = try? fetchedCoreDataCategories.compactMap({ try getCategory(from: $0) })
        else { return }
        
        coreDataManagerDelegate?.didUpdateCategory(trackerCategories, updates)
    }
    
    func didUpdateRecord(_ store: TrackerRecordStoreProtocol, _ updates: RecordUpdates) {
        guard let trackerRecords = trackerRecordStore?.getTrackerRecords() else { return }
        coreDataManagerDelegate?.didUpdateRecords(trackerRecords, updates)
    }
}
