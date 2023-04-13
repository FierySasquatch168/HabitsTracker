//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    var managedObjectContext: NSManagedObjectContext? { get }
    func addCategory(_ category: TrackerCategoryCoreData) throws
}

enum StoreError: Error {
    case decodingErrorInvalidCategoryData
    case decodingErrorInvalidTrackerData
}

enum DataProviderError: Error {
    case failedToInitializeContext
}

enum ConvertError: Error {
    case failedToConvertCoreDataCategoriesToTrackerCategories
}

final class CoreDataManager {
    private let context: NSManagedObjectContext
    
    private let persistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    init() {
        self.context = persistentContainer.newBackgroundContext()
    }
}

extension CoreDataManager: CoreDataManagerProtocol {
    var managedObjectContext: NSManagedObjectContext? {
        return context
    }
    
    func addCategory(_ category: TrackerCategoryCoreData) throws {
        let trackerCategory = TrackerCategoryCoreData(context: context)
        trackerCategory.name = category.name
        trackerCategory.trackers = category.trackers
        try context.save()
    }
}
