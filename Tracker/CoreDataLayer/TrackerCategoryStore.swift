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
//    func fetchCategory(with nameToShow: String) throws -> TrackerCategoryCoreData?
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws
    func getTrackers(with converter: TrackerConverter) -> [TrackerCategory]
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
}

// MARK: - Ext NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let indexesToInsert = insertedIndexes else { return }
        delegate?.didUpdateCategory(self, CategoryUpdates(insertedIndexes: indexesToInsert))
        insertedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        if let indexPath = newIndexPath {
            insertedIndexes?.insert(indexPath.item)
        }
    }
}

// MARK: - Ext TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func getTrackers(with converter: TrackerConverter) -> [TrackerCategory] {
        guard let trackerCategoryCoreDataArray = trackerFetchedResultsController.fetchedObjects,
              let viewCategories = try? trackerCategoryCoreDataArray.compactMap({ try converter.convertToViewCategory(from: $0) })
        else { return [] }
        
        return viewCategories
    }
    
    
    
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws {
        // загрузить действующую категорию с таким именем
        if let existingCategory = trackerFetchedResultsController.fetchedObjects?.filter({ $0.name == categoryName }).first,
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
            throw CoreDataError.failedToSaveContext
        }
    }
}
