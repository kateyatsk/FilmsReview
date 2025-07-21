//
//  FilmsReviewTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 23.06.25.
//

import XCTest
@testable import FilmsReview

final class OnboardingWorkerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let domain = Bundle.main.bundleIdentifier ?? "FilmsReviewTests"
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }

    func testMarkOnboardingAsPassed() {
        XCTAssertFalse(AppSettings.isOnboardingShown, "По умолчанию onboarding не показан")
        
        let worker = OnboardingWorker()
        worker.markOnboardingAsPassed()
        
        XCTAssertTrue(AppSettings.isOnboardingShown, "После markOnboardingAsPassed() флаг должен стать true")
    }

}
