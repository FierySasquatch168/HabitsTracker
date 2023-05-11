//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    var trackerFetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> { get set }
    func getTrackerRecords(with converter: TrackerConverter) -> Set<TrackerRecord>
    func updateRecordsCoreData(record: TrackerRecord) throws
}

struct RecordUpdates {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    weak var delegate: TrackerStorageCoreDataDelegate?
    
    lazy var trackerFetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: false)
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

// MARK: - Ext TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func updateRecordsCoreData(record: TrackerRecord) throws {
        guard let existingRecordSet = trackerFetchedResultsController.fetchedObjects else { return }
        let recordToCompare = existingRecordSet.filter({ $0.id == record.id && $0.date == record.date })
        
        if recordToCompare.isEmpty {
            let coreDataRecord = TrackerRecordCoreData(context: context)
            coreDataRecord.id = record.id
            coreDataRecord.date = record.date
        } else {
            guard let recordToDelete = recordToCompare.first else { return }
            context.delete(recordToDelete)
        }
        
        do {
            try context.save()
        } catch {
            throw CoreDataError.failedToSaveContext
        }
        
    }
    
    func getTrackerRecords(with converter: TrackerConverter) -> Set<TrackerRecord> {
        guard let existingRecords = trackerFetchedResultsController.fetchedObjects else { return [] }
        return Set(existingRecords.compactMap({ converter.convertCoreDataToRecord(from: $0) }))
    }
}

// MARK: - Ext NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let indexesToInsert = insertedIndexes,
              let indexesToDelete = deletedIndexes
        else { return }
        
        delegate?.didUpdateRecord(self, RecordUpdates(insertedIndexes: indexesToInsert, deletedIndexes: indexesToDelete))
        insertedIndexes = nil
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
            fatalError("NSFetchedResultsController didChange .move type")
        case .update:
            fatalError("NSFetchedResultsController didChange .update type")
        @unknown default:
            fatalError("NSFetchedResultsController didChange unknown type")
        }
    }
}
