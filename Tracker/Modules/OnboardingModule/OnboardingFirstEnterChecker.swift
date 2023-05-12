//
//  OnboardingFirstEnterChecker.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 07.05.2023.
//

import Foundation

protocol FirstEnterCheckableProtocol {
    func didEnter() -> Bool
}

final class OnboardingFirstEnterChecker {
    private let onboardingFirstEnterStorage: OnboardingFirstEnterStorage
    
    init(onboardingFirstEnterStorage: OnboardingFirstEnterStorage) {
        self.onboardingFirstEnterStorage = onboardingFirstEnterStorage
    }
}

extension OnboardingFirstEnterChecker: FirstEnterCheckableProtocol {
    func didEnter() -> Bool {
        if onboardingFirstEnterStorage.didEnterBefore == true {
            return false
        } else {
            onboardingFirstEnterStorage.didEnterBefore = true
            return true
        }
    }
}
