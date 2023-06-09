//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func getViewCategories(with converter: TrackerConverter, from trackersCoreData: [TrackerCoreData]) -> [TrackerCategory]
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws
    func updateTracker(trackerCoreData: TrackerCoreData, at categoryName: String) throws
    func deleteTracker(with id: String, from categoryName: String) throws
    func pinTracker(trackerCoreData: TrackerCoreData, at categoryName: String) throws
}

struct CategoryUpdates {
    let insertedIndexes: IndexSet
    let reloadedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    var insertedIndexes: IndexSet?
    var reloadedIndexes: IndexSet?
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
        reloadedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let indexesToInsert = insertedIndexes,
              let indexesToReload = reloadedIndexes,
              let indexesToDelete = deletedIndexes
        else { return }
        delegate?.didUpdateCategory(self, CategoryUpdates(insertedIndexes: indexesToInsert, reloadedIndexes: indexesToReload, deletedIndexes: indexesToDelete))
        insertedIndexes = nil
        reloadedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        
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
            if let indexPath, let newIndexPath {
                deletedIndexes?.insert(indexPath.item)
                insertedIndexes?.insert(newIndexPath.item)
            }
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
    func getCategoriesOLD(with converter: TrackerConverter) -> [TrackerCategory] {
        guard let trackerCategoryCoreDataArray = trackerFetchedResultsController.fetchedObjects,
              let viewCategories = try? trackerCategoryCoreDataArray.compactMap({ try converter.convertToViewCategory(from: $0) })
        else { return [] }
        
        return viewCategories
    }
    
    func getViewCategories(with converter: TrackerConverter, from trackersCoreData: [TrackerCoreData]) -> [TrackerCategory] {        
        // разделить trackersCoreData на закрепленные и незакрепленные
        let pinnedTrackers = trackersCoreData.filter({ $0.isPinned })
        let unpinnedTrackers = trackersCoreData.filter({ !$0.isPinned })
        
        // из закрепленных сделать отдельную вью категорию
        let pinnedViewTrackers = (try? pinnedTrackers.compactMap({ try converter.getTracker(from: $0) })) ?? []
        let pinnedViewCategory = TrackerCategory(
            name: NSLocalizedString(K.LocalizableStringsKeys.pinnedCategoryName, comment: "Pinned  category name"),
            trackers: pinnedViewTrackers)
        
        var finalViewCategories: [TrackerCategory] = []
        finalViewCategories.append(pinnedViewCategory)
        
        // закрепленные разделить по категориям из кордаты
        unpinnedTrackers.forEach { trackerCoredata in
            let trackersCoreDataFilteredByCategoryName = unpinnedTrackers.filter({ $0.category?.name == trackerCoredata.category?.name })
            let viewTrackersFilteredByCategoryName = (try? trackersCoreDataFilteredByCategoryName.compactMap({ try converter.getTracker(from: $0)})) ?? []
            let viewCategory = TrackerCategory(name: trackerCoredata.category?.name ?? "Error", trackers: viewTrackersFilteredByCategoryName)
            finalViewCategories.append(viewCategory)
        }
        
        return finalViewCategories
    }
    
    func saveTracker(with trackerCoreData: TrackerCoreData, to categoryName: String) throws {
        if let existingCategory = trackerFetchedResultsController.fetchedObjects?.first(where: { $0.name == categoryName }) {
            existingCategory.addToTrackers(trackerCoreData)
        } else {
            let newCategory = createTrackerCategoryCoreData(with: categoryName)
            newCategory.addToTrackers(trackerCoreData)
        }
        
        try context.save()
    }
    
    func updateTracker(trackerCoreData: TrackerCoreData, at categoryName: String) throws {
        removeTracker(trackerCoreData: trackerCoreData)
        insertTracker(trackerCoreData: trackerCoreData, at: categoryName)
        
        do {
            try context.save()
//            print(trackerFetchedResultsController.fetchedObjects)
        } catch {
            throw CoreDataError.failedToUpdateTracker
        }
    }
    
    func deleteTracker(with id: String, from categoryName: String) throws {
        guard let trackerCategoryCoreData = trackerFetchedResultsController.fetchedObjects?.filter({ $0.name == categoryName }).first,
              let coreDataTrackers = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData],
              let trackerToDelete = coreDataTrackers.filter({ $0.stringID == id }).first
        else { return }
        
        if trackerCategoryCoreData.trackers?.count == 1 { deleteCategory(with: categoryName) }
        context.delete(trackerToDelete)
        
        do {
            try context.save()
//            print(trackerFetchedResultsController.fetchedObjects)
        } catch {
            throw CoreDataError.failedToDeleteTracker
        }
    }
    
    func pinTracker(trackerCoreData: TrackerCoreData, at categoryName: String) throws {
        trackerCoreData.isPinned.toggle()
        
        do {
            try context.save()
        } catch {
            throw CoreDataError.failedToPinTracker
        }
    }
}

private extension TrackerCategoryStore {
    func createTrackerCategoryCoreData(with categoryName: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.name = categoryName
        category.trackers = NSSet(array: [])
        
        return category
    }
    
    func deleteCategory(with categoryName: String?) {
        guard let categoryToDelete = trackerFetchedResultsController.fetchedObjects?.filter({ $0.name == categoryName }).first else { return }
        context.delete(categoryToDelete)
    }
    
    func removeTracker(trackerCoreData: TrackerCoreData) {
        let categoryToRemoveTrackerFrom = trackerFetchedResultsController.fetchedObjects?.first(where: { $0.name == trackerCoreData.category?.name })
        categoryToRemoveTrackerFrom?.removeFromTrackers(trackerCoreData)
        if categoryToRemoveTrackerFrom?.trackers?.count == 0 { deleteCategory(with: categoryToRemoveTrackerFrom?.name) }
    }
    
    func insertTracker(trackerCoreData: TrackerCoreData, at categoryName: String) {
        if let categoryToInsertTrackerTo = trackerFetchedResultsController.fetchedObjects?.first(where: { $0.name == categoryName }) {
            categoryToInsertTrackerTo.addToTrackers(trackerCoreData)
        } else {
            let newCategory = createTrackerCategoryCoreData(with: categoryName)
            newCategory.addToTrackers(trackerCoreData)
        }
    }
}
