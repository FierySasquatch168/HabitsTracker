//
//  OnboardingFirstEnterChecker.swift
//  Tracker
//
//  Created by Aleksandr Eliseev on 07.05.2023.
//

import Foundation

protocol FirstEnterCheckableProtocol {
    func shouldShowOnboarding() -> Bool
    func didCompleteOnboarding()
}

final class OnboardingFirstEnterChecker {
    private let onboardingFirstEnterStorage: OnboardingFirstEnterStorage
    
    init(onboardingFirstEnterStorage: OnboardingFirstEnterStorage) {
        self.onboardingFirstEnterStorage = onboardingFirstEnterStorage
    }
}

extension OnboardingFirstEnterChecker: FirstEnterCheckableProtocol {
    func shouldShowOnboarding() -> Bool {
        onboardingFirstEnterStorage.hasEnteredBefore ? false : true
    }
    
    func didCompleteOnboarding() {
        onboardingFirstEnterStorage.hasEnteredBefore = true
    }
}

