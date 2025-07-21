//
//  OnboardingInteractorTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 20.07.25.
//

import XCTest
@testable import FilmsReview

final class PresenterSpy: OnboardingPresenterProtocol {
    var viewController: ViewControllerProtocol?
    private(set) var lastIndex: Int?
    private(set) var lastIsLast: Bool?
    private(set) var didFinish = false

    func presentSlideChanged(index: Int, isLast: Bool) {
        lastIndex = index
        lastIsLast = isLast
    }

    func presentFinish() {
        didFinish = true
    }
}

final class OnboardingInteractorTests: XCTestCase {
    var interactor: OnboardingInteractor!
    var presenter: PresenterSpy!

    override func setUp() {
        super.setUp()
        
        presenter = PresenterSpy()
        let worker = OnboardingWorker()
        interactor = OnboardingInteractor(worker: worker)
        interactor.presenter = presenter
    }

    func testDidScrollToSlideNotLast() {
        interactor.didScrollToSlide(at: 1)
        XCTAssertEqual(presenter.lastIndex, 1)
        XCTAssertEqual(presenter.lastIsLast, false)
    }

    func testDidScrollToSlideLast() {
        let last = Onboarding.slides.count - 1
        interactor.didScrollToSlide(at: last)
        XCTAssertEqual(presenter.lastIndex, last)
        XCTAssertEqual(presenter.lastIsLast, true)
    }

    func testSkipTappedCallsFinishAndSetsFlag() {
        AppSettings.isOnboardingShown = false
        interactor.skipTapped()
        XCTAssertTrue(presenter.didFinish)
        XCTAssertTrue(AppSettings.isOnboardingShown)
    }
}
