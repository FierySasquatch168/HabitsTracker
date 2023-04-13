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
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    var description: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
             return "Суббота"
        case .sunday:
            return "Воскресенье"
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
}
