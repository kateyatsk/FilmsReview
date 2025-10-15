//
//  ForgotPasswordTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.07.25.
//

import XCTest
@testable import FilmsReview

final class ForgotPasswordVCSpy: UIViewController, ForgotPasswordVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private(set) var didShowCheckEmail = false

    func showCheckYourEmailScreen() {
        didShowCheckEmail = true
    }
}

final class MockAuthInteractor: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var resetPasswordCalled = false
    var passedEmail: String?

    func resetPassword(email: String) {
        resetPasswordCalled = true
        passedEmail = email
    }

    func register(email: String, password: String) {}
    func login(email: String, password: String) {}
    func signOut(completion: @escaping (Error?) -> Void) {}
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {}
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void) {}
    func startEmailVerificationMonitoring() {}
    func stopEmailVerificationMonitoring() {}
    func deleteAccount(completion: @escaping (Error?) -> Void) {}
    func validateEmail(_ email: String) -> Bool { return true }
    func createProfile(name: String, birthday: Date, avatarData: Data?) {}
    func saveFavoriteGenres(_ genres: [String]) {}
    func fetchTMDBGenres(language: String) {}
}

final class MockAuthRouter: AuthenticationRouterProtocol {
    var viewController: (any ViewControllerProtocol)?
    private(set) var navigateToCheckEmailCalled = false
    private(set) var passedEmail: String?

    func navigateToCheckYourEmail(email: String) {
        navigateToCheckEmailCalled = true
        passedEmail = email
    }
    func navigateToLogin() {}
    func navigateToSignUp() {}
    func routeToEmailVerification() {}
    func navigateToForgotPassword() {}
    func navigateToCreateProfile() {}
    func navigateToChooseInterests() {}
}

final class ForgotPasswordTests: XCTestCase {
    var sut: ForgotPasswordViewController!
    var interactor: MockAuthInteractor!
    var router: MockAuthRouter!

    override func setUp() {
        super.setUp()
        sut = ForgotPasswordViewController()
        interactor = MockAuthInteractor()
        router = MockAuthRouter()
        sut.interactor = interactor
        sut.router = router
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        interactor = nil
        router = nil
        super.tearDown()
    }

    func testContinueTappedWithEmptyEmailShowsAlert() {
        sut.emailField.text = ""
        sut.continueTapped()
        XCTAssertFalse(interactor.resetPasswordCalled)
    }

    func testContinueTappedWithValidEmailCallsResetPassword() {
        sut.emailField.text = "test@example.com"
        sut.continueTapped()
        XCTAssertTrue(interactor.resetPasswordCalled)
        XCTAssertEqual(interactor.passedEmail, "test@example.com")
    }

    func testShowCheckYourEmailScreenNavigatesToCheckYourEmail() {
        sut.emailField.text = "test@example.com"
        sut.showCheckYourEmailScreen()
        XCTAssertTrue(router.navigateToCheckEmailCalled)
        XCTAssertEqual(router.passedEmail, "test@example.com")
    }
}
