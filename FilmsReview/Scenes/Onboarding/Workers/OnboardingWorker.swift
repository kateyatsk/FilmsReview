//
//  OnboardingWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation

protocol OnboardingWorkerProtocol {
    func markOnboardingAsPassed()
}

final class OnboardingWorker: OnboardingWorkerProtocol {
    func markOnboardingAsPassed() {
        AppSettings.isOnboardingShown = true
    }
}
