//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func fetchTrackerCategories() throws -> [TrackerCategory]
    func saveTracker(tracker: Tracker, to category: String) throws
}

protocol CoreDataManagerDelegate: AnyObject {
    func didUpdateCategory(_ updatedCategories: [TrackerCategory], _ updates: CategoryUpdates)
}

protocol TrackerStorageCoreDataDelegate: AnyObject {
    var managedObjectContext: NSManagedObjectContext { get }
    func didUpdateCategory(_ store: TrackerCategoryStoreProtocol, _ updates: CategoryUpdates)
} 

final class CoreDataManager {
    private let context: NSManagedObjectContext
    
    weak var coreDataManagerDelegate: CoreDataManagerDelegate?
    
    private var trackerCategoryStore: TrackerCategoryStoreProtocol?
    private var trackerRecordStore: TrackerRecordStoreProtocol?
    private var trackerStore: TrackerStoreProtocol?

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
    private func makeCategory(from category: TrackerCategory) -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = category.name
        trackerCategoryCoreData.trackers = NSSet(array: category.trackers.compactMap({ trackerStore?.makeTracker(from: $0) }))
        return trackerCategoryCoreData
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
    func fetchTrackerCategories() throws -> [TrackerCategory] {
        guard let categoriesCoreData = trackerCategoryStore?.trackerFetchedResultsController.fetchedObjects,
              let trackersCoreData = trackerStore?.trackerFetchedResultsController.fetchedObjects
        else {
            return []
        }
        
        var trackerCategories: [TrackerCategory] = []
        
        categoriesCoreData.forEach { trackerCategoryCoreData in
            let filteredCoreDataTrackers = trackersCoreData.filter({ $0.category?.name == trackerCategoryCoreData.name })
            let finalTrackers = try? filteredCoreDataTrackers.compactMap({ try trackerStore?.getTracker(from: $0) })
            let category = TrackerCategory(name: trackerCategoryCoreData.name ?? "", trackers: finalTrackers ?? [])
            trackerCategories.append(category)
        }
        
        return trackerCategories
    }
   
    func saveTracker(tracker: Tracker, to category: String) throws {
        guard let trackerCoreData = trackerStore?.makeTracker(from: tracker),
              let request = trackerCategoryStore?.trackerFetchedResultsController.fetchRequest,
              var fetchedObjects = trackerCategoryStore?.trackerFetchedResultsController.fetchedObjects
        else {
            return
        }
        
        
        // загрузить действующую категорию с таким именем
        if let existingCategory = try? trackerCategoryStore?.fetchCategory(from: request, with: category),
           var newCoreDataTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] {
            // если она есть, поменять у нее свойство трэкерс и загрузить обратно
            newCoreDataTrackers.append(trackerCoreData)
            existingCategory.trackers = NSSet(array: newCoreDataTrackers)
            // TODO: Работает до сюда
        } else {
            // если ее нет, создать новую
            // TODO: Работает только для первой категории
            let newCategory = TrackerCategoryCoreData(context: context)
            var newCoreDataTrackers: [TrackerCoreData] = []
            newCoreDataTrackers.append(trackerCoreData)
            newCategory.name = category
            newCategory.trackers = NSSet(array: [trackerCoreData])
            fetchedObjects.append(newCategory)
        }
        
        do {
            try context.save()
        } catch {
            throw StoreError.failedToSaveContext
        }
    }
}

// MARK: - Ext
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
}
