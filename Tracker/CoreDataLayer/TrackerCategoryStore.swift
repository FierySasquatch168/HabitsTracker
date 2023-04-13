//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func fetchTrackerCategories() throws -> [TrackerCategory]
    func saveTrackerCategories(_ category: TrackerCategory) throws
}

struct CategoryUpdates {
    let insertedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    var insertedIndexes: IndexSet?
    // TODO: set the delegate
    weak var delegate: TrackerCategoryDelegate?
    
    private let context: NSManagedObjectContext
    private let coreDataManager: CoreDataManagerProtocol
    
    private lazy var trackerFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: false)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    init(coreDataManager: CoreDataManagerProtocol, delegate: TrackerCategoryDelegate) throws {
        guard let context = coreDataManager.managedObjectContext else {
            throw DataProviderError.failedToInitializeContext
        }
        self.coreDataManager = coreDataManager
        self.context = context
        self.delegate = delegate
    }
    
    private func getCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = categoryCoreData.name,
              let coreDataTrackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData],
              let trackers = try? coreDataTrackers.map({ try getTracker(from: $0) })
        else {
            throw StoreError.decodingErrorInvalidCategoryData
        }

        return TrackerCategory(name: name, trackers: trackers)
    }

    private func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let name = trackerCoreData.name,
              let weekDays = trackerCoreData.schedule,
              let hexColor = trackerCoreData.color,
              let emojie = trackerCoreData.emojie
        else {
            throw StoreError.decodingErrorInvalidCategoryData
        }

        let color = UIColorMarshalling.color(from: hexColor)
        let schedule = WeekDays.getWeekDaysArray(from: weekDays)

        return Tracker(name: name, color: color, emoji: emojie, schedule: schedule)
    }
    
    private func makeCategory(from category: TrackerCategory) -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = category.name
        trackerCategoryCoreData.trackers = NSSet(array: category.trackers.map({ makeTracker(from: $0) }))
        return trackerCategoryCoreData
    }
    
    private func makeTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = WeekDays.getString(from: tracker.schedule)
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojie = tracker.emoji
        return trackerCoreData
    }
    
}

// MARK: - Ext NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("TrackerCategoryStore controllerWillChangeContent works")
        insertedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let indexesToInsert = insertedIndexes else { return }
        delegate?.didUpdateCategory(self, CategoryUpdates(insertedIndexes: indexesToInsert))
        insertedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TrackerCategoryStore didChange anObject insert index")
        if let indexPath = newIndexPath {
            insertedIndexes?.insert(indexPath.item)
        }
    }
}

// MARK: - Ext TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func fetchTrackerCategories() throws -> [TrackerCategory] {
        guard let objects = self.trackerFetchedResultsController.fetchedObjects,
              let trackerCategory = try? objects.map({ try self.getCategory(from: $0) })
        else {
            throw StoreError.decodingErrorInvalidTrackerData
        }
        return trackerCategory
    }
    
    func saveTrackerCategories(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = makeCategory(from: category)
        try coreDataManager.addCategory(trackerCategoryCoreData)
    }
}
