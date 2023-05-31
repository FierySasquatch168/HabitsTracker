//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws
    func deleteTracker(with id: String, from categoryName: String) throws
    func updateTracker(tracker: Tracker, at categoryName: String) throws
    func getCategories(with converter: TrackerConverter) -> [TrackerCategory]
}

struct CategoryUpdates {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?

    weak var delegate: TrackerStorageDataStoreDelegate?
    
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
    
    init(delegate: TrackerStorageDataStoreDelegate) {
        self.context = delegate.managedObjectContext
        self.delegate = delegate
    }
}

// MARK: - Ext NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let indexesToInsert = insertedIndexes,
              let indexesToDelete = deletedIndexes
        else { return }
        delegate?.didUpdateCategory(self, CategoryUpdates(insertedIndexes: indexesToInsert, deletedIndexes: indexesToDelete))
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
//        if let indexPath = newIndexPath {
//            insertedIndexes?.insert(indexPath.item)
//        }
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = newIndexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .move:
            fatalError("NSFetchedResultsController didChange .move type")
        case .update:
            if let indexPath = newIndexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        @unknown default:
            fatalError("NSFetchedResultsController didChange unknown type")
        }
    }
}

// MARK: - Ext TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getCategories(with converter: TrackerConverter) -> [TrackerCategory] {
        guard let trackerCategoryCoreDataArray = trackerFetchedResultsController.fetchedObjects,
              let viewCategories = try? trackerCategoryCoreDataArray.compactMap({ try converter.convertToViewCategory(from: $0) })
        else { return [] }
        
        return viewCategories
    }
    
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws {
        if let existingCategory = trackerFetchedResultsController.fetchedObjects?.first(where: { $0.name == categoryName }) {
            existingCategory.addToTrackers(trackerCoreData)
        } else {
            let newCategory = try createTrackerCategoryCoreData(with: categoryName)
            newCategory.addToTrackers(trackerCoreData)
        }
        
        try context.save()
    }
    
    func updateTracker(tracker: Tracker, at categoryName: String) throws {
        guard let storedObjects = trackerFetchedResultsController.fetchedObjects else { return }
        var trackerToModify: TrackerCoreData?
        for category in storedObjects {
            guard let storedTrackers = category.trackers?.allObjects as? [TrackerCoreData] else { return }
            if storedTrackers.contains(where: { $0.stringID == tracker.stringID }) {
                trackerToModify = storedTrackers.first(where: { $0.stringID == tracker.stringID })
            }
        }
        
        trackerToModify?.category?.name = categoryName
        trackerToModify?.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerToModify?.emojie = tracker.emoji
        trackerToModify?.name = tracker.name
        trackerToModify?.schedule = WeekDays.getString(from: tracker.schedule)
        
        do {
            try context.save()
        } catch {
            throw CoreDataError.failedToUpdateTracker
        }
    }
    
    func deleteTracker(with id: String, from categoryName: String) throws {
        guard let trackerCategoryCoreData = trackerFetchedResultsController.fetchedObjects?.filter({ $0.name == categoryName }).first,
              var coreDataTrackers = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData],
              let trackerToDelete = coreDataTrackers.filter({ $0.stringID == id }).first
        else { return }
        
        
        coreDataTrackers.removeAll(where: { $0.stringID == id })
        context.delete(trackerToDelete)
        coreDataTrackers.isEmpty ? context.delete(trackerCategoryCoreData) : ()
        
        do {
            try context.save()
        } catch {
            throw CoreDataError.failedToDeleteTracker
        }
    }
}

private extension TrackerCategoryStore {
    func createTrackerCategoryCoreData(with categoryName: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.name = categoryName
        category.trackers = NSSet(array: [])
        
        return category
    }
}
