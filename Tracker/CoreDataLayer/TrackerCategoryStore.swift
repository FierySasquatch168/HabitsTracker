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
    func fetchCategory(with nameToShow: String) throws -> TrackerCategoryCoreData?
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
    func fetchCategory(with nameToShow: String) throws -> TrackerCategoryCoreData? {
        let request = trackerFetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@",
                                        argumentArray: ["name", nameToShow])
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name,
                             ascending: false)
        ]
        do {
            let category = try context.fetch(request).first
            return category
        } catch {
            throw CoreDataError.decodingErrorInvalidCategoryData
        }
    }
}
