//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerStoreProtocol {
    func makeTracker(from tracker: Tracker, with context: NSManagedObjectContext) -> TrackerCoreData
    func fetchTrackers(with converter: TrackerConverter) -> [Tracker]
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
    func makeTracker(from tracker: Tracker, with context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = WeekDays.getString(from: tracker.schedule)
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojie = tracker.emoji
        // При сохранении задаем в модели КорДаты текстовый айди
        trackerCoreData.stringID = tracker.id.uuidString
        trackerCoreData.isPinned = tracker.isPinned
        return trackerCoreData
    }
    
    func fetchTrackers(with converter: TrackerConverter) -> [Tracker] {
        guard let trackerCategoryCoreDataArray = trackerFetchedResultsController.fetchedObjects,
              let viewTrackers = try? trackerCategoryCoreDataArray.compactMap({ try converter.getTracker(from: $0) })
        else { return [] }
        
        return viewTrackers
        
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
