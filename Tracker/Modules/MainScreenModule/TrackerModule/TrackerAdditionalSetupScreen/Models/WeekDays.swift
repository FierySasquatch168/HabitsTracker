//
//  WeekDays.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 30.03.2023.
//

import Foundation

enum WeekDays: Int, CustomStringConvertible, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameMon, comment: "ShortDayName")
        case .tuesday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameTue, comment: "ShortDayName")
        case .wednesday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameWed, comment: "ShortDayName")
        case .thursday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameThu, comment: "ShortDayName")
        case .friday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameFri, comment: "ShortDayName")
        case .saturday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameSat, comment: "ShortDayName")
        case .sunday:
            return NSLocalizedString(K.LocalizableStringsKeys.shortNameSun, comment: "ShortDayName")
        }
    }
    
    var description: String {
        switch self {
        case .monday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameMon, comment: "FullDayName")
        case .tuesday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameTue, comment: "FullDayName")
        case .wednesday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameWed, comment: "FullDayName")
        case .thursday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameThu, comment: "FullDayName")
        case .friday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameFri, comment: "FullDayName")
        case .saturday:
             return NSLocalizedString(K.LocalizableStringsKeys.longNameSat, comment: "FullDayName")
        case .sunday:
            return NSLocalizedString(K.LocalizableStringsKeys.longNameSun, comment: "FullDayName")
        }
    }
    
    static func getWeekDay(from text: String) -> WeekDays? {
        return WeekDays.allCases.filter({ $0.description == text }).first
    }
    
    static func getString(from weekDays: [WeekDays]) -> String {
        var result: [String] = []
        for i in 0..<WeekDays.allCases.count{
            weekDays.contains(WeekDays.allCases[i]) ? result.append("1") : result.append("0")
        }
        
        return result.joined()

    }
    
    static func getWeekDaysArray(from code: String) -> [WeekDays] {
        var weekDays: [WeekDays] = []
        for i in 0..<Array(code).count {
            Array(code)[i] == "1" ? weekDays.append(WeekDays.allCases[i]) : ()
        }
        
        return weekDays
    }
    
    static func populateShortWeekDaysSubtitle(from weekDay: [WeekDays]) -> String {
        return weekDay.count == WeekDays.allCases.count ? NSLocalizedString(K.LocalizableStringsKeys.allDays, comment: "") : weekDay.map({ $0.shortName }).joined(separator: ", ")
    }
}
