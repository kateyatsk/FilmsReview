//
//  CheckEmailViewControllerTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 30.07.25.
//

import XCTest
@testable import FilmsReview

final class MockCheckEmailRouter: AuthenticationRouterProtocol {
    var viewController: (any ViewControllerProtocol)?
    private(set) var navigateToLoginCalled = false

    func navigateToLogin() { navigateToLoginCalled = true }
    func navigateToCheckYourEmail(email: String) {}
    func navigateToSignUp() {}
    func routeToEmailVerification() {}
    func navigateToForgotPassword() {}
}

final class CheckEmailViewControllerTests: XCTestCase {
    var sut: CheckEmailViewController!
    var router: MockCheckEmailRouter!

    override func setUp() {
        super.setUp()
        sut = CheckEmailViewController()
        router = MockCheckEmailRouter()
        sut.router = router
        sut.email = "test@example.com"
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        router = nil
        super.tearDown()
    }

    func testMessageLabelContainsEmail() {
        let label = sut.view.subviews.compactMap { $0 as? UILabel }.first(where: { $0.text?.contains("test@example.com") == true })
        XCTAssertNotNil(label, "Сообщение должно содержать корректный email")
    }

    func testNavigateToLoginCallsRouter() {
        sut.navigateToLoginScreen()
        XCTAssertTrue(router.navigateToLoginCalled, "Должен вызываться navigateToLogin() при нажатии кнопки Back")
    }
}
