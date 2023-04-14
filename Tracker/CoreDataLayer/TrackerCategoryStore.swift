//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    var trackerFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> { get set }
//    func fetchTrackerCategories() throws -> [TrackerCategory]
}

struct CategoryUpdates {
    let insertedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    var insertedIndexes: IndexSet?
    // TODO: set the delegate
    weak var delegate: TrackerStorageCoreDataDelegate?
    
    private let context: NSManagedObjectContext
    
    lazy var trackerFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
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
    
    init(delegate: TrackerStorageCoreDataDelegate) {
        self.context = delegate.managedObjectContext
        self.delegate = delegate
    }
    
//    private func getCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
//        guard let name = categoryCoreData.name,
//              let coreDataTrackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData],
//              let trackers = try? coreDataTrackers.map({ try trackerStore.getTracker(from: $0) })
//        else {
//            throw StoreError.decodingErrorInvalidCategoryData
//        }
//
//        return TrackerCategory(name: name, trackers: trackers)
//    }
    
//    private func makeCategory(from category: TrackerCategory) -> TrackerCategoryCoreData {
//        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
//        trackerCategoryCoreData.name = category.name
//        trackerCategoryCoreData.trackers = NSSet(array: category.trackers.map({ trackerStore.makeTracker(from: $0) }))
//        return trackerCategoryCoreData
//    }
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
//    func fetchTrackerCategories() throws -> [TrackerCategory] {
//        guard let objects = self.trackerFetchedResultsController.fetchedObjects,
//              let trackerCategory = try? objects.map({ try self.getCategory(from: $0) })
//        else {
//            throw StoreError.decodingErrorInvalidTrackerData
//        }
//        return trackerCategory
//    }
//
//    func createCoreDataCategories() throws -> [TrackerCategoryCoreData] {
//        guard let objects = self.trackerFetchedResultsController.fetchedObjects else { return [] }
//        return objects
//    }
}
