//
//  TrackerConverter.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 11.05.2023.
//

import Foundation

protocol TrackerConverterProtocol {
    func convertToViewCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
    func convertStoredDataToTrackerRecord(from record: TrackerRecordCoreData) -> TrackerRecord?
}

final class TrackerConverter: TrackerConverterProtocol {
    func convertToViewCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = categoryCoreData.name,
              let coreDataTrackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData],
              let trackers = try? coreDataTrackers.compactMap({ try getTracker(from: $0) })
        else {
            throw CoreDataError.decodingErrorInvalidCategoryData
        }
        
        return TrackerCategory(name: name, trackers: trackers)
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let name = trackerCoreData.name,
              let weekDays = trackerCoreData.schedule,
              let hexColor = trackerCoreData.color,
              let emojie = trackerCoreData.emojie
        else {
            throw CoreDataError.decodingErrorInvalidCategoryData
        }

        let color = UIColorMarshalling.color(from: hexColor)
        let schedule = WeekDays.getWeekDaysArray(from: weekDays)

        return Tracker(name: name, color: color, emoji: emojie, schedule: schedule, stringID: trackerCoreData.stringID)
    }
    
    func convertStoredDataToTrackerRecord(from record: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = record.id,
              let date = record.date
        else { return nil }
        
        return TrackerRecord(id: id, date: date)
    }
}
