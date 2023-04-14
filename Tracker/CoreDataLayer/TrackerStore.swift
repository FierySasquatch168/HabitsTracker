//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerStoreProtocol {
    var trackerFetchedResultsController: NSFetchedResultsController<TrackerCoreData> { get set }
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
    func makeTracker(from tracker: Tracker) -> TrackerCoreData
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerStorageCoreDataDelegate?
    
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
    
    init(delegate: TrackerStorageCoreDataDelegate) {
        self.context = delegate.managedObjectContext
        self.delegate = delegate
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
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
    
    func makeTracker(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = WeekDays.getString(from: tracker.schedule)
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojie = tracker.emoji
        return trackerCoreData
    }
    
    
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
