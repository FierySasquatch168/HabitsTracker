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
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameMon, comment: "ShortDayName")
        case .tuesday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameTue, comment: "ShortDayName")
        case .wednesday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameWed, comment: "ShortDayName")
        case .thursday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameThu, comment: "ShortDayName")
        case .friday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameFri, comment: "ShortDayName")
        case .saturday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameSat, comment: "ShortDayName")
        case .sunday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.shortNameSun, comment: "ShortDayName")
        }
    }
    
    var description: String {
        switch self {
        case .monday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameMon, comment: "FullDayName")
        case .tuesday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameTue, comment: "FullDayName")
        case .wednesday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameWed, comment: "FullDayName")
        case .thursday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameThu, comment: "FullDayName")
        case .friday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameFri, comment: "FullDayName")
        case .saturday:
             return NSLocalizedString(Constants.LocalizableStringsKeys.longNameSat, comment: "FullDayName")
        case .sunday:
            return NSLocalizedString(Constants.LocalizableStringsKeys.longNameSun, comment: "FullDayName")
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
        return weekDay.count == WeekDays.allCases.count ? NSLocalizedString(Constants.LocalizableStringsKeys.allDays, comment: "") : weekDay.map({ $0.shortName }).joined(separator: ", ")
    }
}
