//
//  Context.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 03.06.2023.
//

import Foundation
import CoreData

final class Context {
    let context: NSManagedObjectContext
    
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
