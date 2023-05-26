//
//  CoreDataError.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 13.04.2023.
//

import Foundation

enum CoreDataError: Error {
    case decodingErrorInvalidCategoryData
    case decodingErrorInvalidTrackerData
    case failedToInitializeContext
    case failedToConvertCoreDataCategoriesToTrackerCategories
    case failedToConvertCoreDataTrackersToViewTracker
    case failedToSaveContext
    case failedToLoadRecords
    case failedToManageRecords
    case failedToDeleteTracker
    case failedToUpdateTracker
}
