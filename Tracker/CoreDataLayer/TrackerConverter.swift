//
//  TrackerConverter.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 11.05.2023.
//

import Foundation
import CoreData

protocol TrackerConverterProtocol {
    func convertToViewCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
    func makeTracker(from tracker: Tracker, with context: NSManagedObjectContext) -> TrackerCoreData
    func convertCoreDataToRecord(from record: TrackerRecordCoreData) -> TrackerRecord?
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
    
    func makeTracker(from tracker: Tracker, with context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = WeekDays.getString(from: tracker.schedule)
        trackerCoreData.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emojie = tracker.emoji
        // При сохранении задаем в модели КорДаты текстовый айди
        trackerCoreData.stringID = tracker.id.uuidString
        return trackerCoreData
    }
    
    func convertCoreDataToRecord(from record: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = record.id,
              let date = record.date
        else { return nil }
        
        return TrackerRecord(id: id, date: date)
    }
}
