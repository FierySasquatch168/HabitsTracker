//
//  OnboardingFirstEnterChecker.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 07.05.2023.
//

import Foundation

protocol Checkable {
    static func firstEntrance() -> Bool
}

final class OnboardingFirstEnterChecker { }

extension OnboardingFirstEnterChecker: Checkable {
    static func firstEntrance() -> Bool {
        if UserDefaults.standard.bool(forKey: Constants.FirstLaunchCheck.firstLaunch) == true {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: Constants.FirstLaunchCheck.firstLaunch)
            return true
        }
    }
}
