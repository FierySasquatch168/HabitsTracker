//
//  OnboardingFirstEnterStorage.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 12.05.2023.
//

import Foundation

final class OnboardingFirstEnterStorage {
    let userDefaults = UserDefaults.standard
    
    var hasEnteredBefore: Bool {
        get {
            userDefaults.bool(forKey: "FirstLaunch")
        }
        set {
            userDefaults.set(newValue, forKey: "FirstLaunch")
        }
    }
}
