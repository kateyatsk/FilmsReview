//
//  OnboardingPresenterTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 20.07.25.
//

import XCTest
@testable import FilmsReview

class ViewControllerSpy: UIViewController, OnboardingViewControllerProtocol {
    var interactor: InteractorProtocol?
    var router: RouterProtocol?
    
    private(set) var pageControlPage: Int?
    private(set) var skipHidden: Bool?
    private(set) var didNavigate = false
    
    func updatePageControl(currentPage: Int) {
        pageControlPage = currentPage
    }
    func toggleSkipButton(hidden: Bool) {
        skipHidden = hidden
    }
    func navigateToMainApp() {
        didNavigate = true
    }
}

final class OnboardingPresenterTests: XCTestCase {
    var presenter: OnboardingPresenter!
    var viewController: ViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        viewController = ViewControllerSpy()
        presenter = OnboardingPresenter()
        presenter.viewController = viewController
    }
    
    func testPresentSlideChanged() {
        presenter.presentSlideChanged(index: 0, isLast: false)
        XCTAssertEqual(viewController.pageControlPage, 0)
        XCTAssertEqual(viewController.skipHidden, false)
        
        presenter.presentSlideChanged(index: 2, isLast: true)
        XCTAssertEqual(viewController.pageControlPage, 2)
        XCTAssertEqual(viewController.skipHidden, true)
    }
    
    func testPresentFinish() {
        presenter.presentFinish()
        XCTAssertTrue(viewController.didNavigate)
    }
    
}
