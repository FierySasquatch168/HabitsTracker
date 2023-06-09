//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerStoreProtocol {
    func createTracker(from tracker: Tracker) -> TrackerCoreData
    func fetchTrackers(with converter: TrackerConverter) -> [Tracker]
    func fetchCoreDataTrackers() -> [TrackerCoreData]
    func updateCoreDataTracker(from tracker: Tracker) -> TrackerCoreData?
    func getCoreDataTracker(from tracker: Tracker) -> TrackerCoreData?
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerStorageDataStoreDelegate?
    
    lazy var trackerFetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: false)
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

// MARK: - Ext TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    func createTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.updateWithNewValues(from: tracker)
        return trackerCoreData
    }
    
    func fetchTrackers(with converter: TrackerConverter) -> [Tracker] {
        guard let trackerCategoryCoreDataArray = trackerFetchedResultsController.fetchedObjects,
              let viewTrackers = try? trackerCategoryCoreDataArray.compactMap({ try converter.getTracker(from: $0) })
        else { return [] }
        
        return viewTrackers
        
    }
    
    func fetchCoreDataTrackers() -> [TrackerCoreData] {
        return trackerFetchedResultsController.fetchedObjects ?? []
    }
    
    func updateCoreDataTracker(from tracker: Tracker) -> TrackerCoreData? {
        let existingTrackerCoreData = getCoreDataTracker(from: tracker)
        existingTrackerCoreData?.updateWithNewValues(from: tracker)
        return existingTrackerCoreData
    }
    
    func getCoreDataTracker(from tracker: Tracker) -> TrackerCoreData? {
        return trackerFetchedResultsController.fetchedObjects?.first(where: { $0.stringID == tracker.stringID })
    }
}

// MARK: - Ext NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
