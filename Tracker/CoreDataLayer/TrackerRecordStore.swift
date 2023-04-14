//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.04.2023.
//

import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStorageCoreDataDelegate?
    
    init(delegate: TrackerStorageCoreDataDelegate) {
        self.context = delegate.managedObjectContext
        self.delegate = delegate
    }
}
