//
//  StoreError.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 13.04.2023.
//

import Foundation

enum StoreError: Error {
    case decodingErrorInvalidCategoryData
    case decodingErrorInvalidTrackerData
    case failedToInitializeContext
    case failedToConvertCoreDataCategoriesToTrackerCategories
    case failedToSaveContext
}
