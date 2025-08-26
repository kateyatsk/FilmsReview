//
//  AuthenticationPresenterTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 5.08.25.
//

import XCTest
@testable import FilmsReview

private final class SpyForgotPasswordVC: UIViewController, ForgotPasswordVCProtocol {
    var interactor: (any FilmsReview.InteractorProtocol)?
    var router: (any FilmsReview.RouterProtocol)?
    
    private(set) var didShowCheckEmail = false
    func showCheckYourEmailScreen() {
        didShowCheckEmail = true
    }
}

private final class SpyVerificationVC: UIViewController, ViewControllerProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
}

private final class StubAuthRouter: AuthenticationRouterProtocol {
    weak var viewController: ViewControllerProtocol?
    private(set) var navigateToCreateProfileCalled = false

    func navigateToLogin() {}
    func navigateToSignUp() {}
    func routeToEmailVerification() {}
    func navigateToForgotPassword() {}
    func navigateToCheckYourEmail(email: String) {}
    func navigateToCreateProfile() {
        navigateToCreateProfileCalled = true
    }
}

final class AuthenticationPresenterTests: XCTestCase {
    var presenter: AuthenticationPresenter!

    override func setUp() {
        super.setUp()
        presenter = AuthenticationPresenter()
    }

    func testDidResetPassword() {
        let vc = SpyForgotPasswordVC()
        presenter.viewController = vc
        presenter.didResetPassword()
        XCTAssertTrue(vc.didShowCheckEmail,
                      "didResetPassword() презентера должен вызвать showCheckYourEmailScreen() у VC")
    }

    func testDidConfirmEmail() {
        let vc = SpyVerificationVC()
        let router = StubAuthRouter()
        vc.router = router
        presenter.viewController = vc
        presenter.didConfirmEmail()
        XCTAssertTrue(router.navigateToCreateProfileCalled,
                      "didConfirmEmail() презентера должен вызвать navigateToCreateProfile() у роутера")
    }
}
