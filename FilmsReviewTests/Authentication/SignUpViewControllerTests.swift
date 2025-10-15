//
//  SignUpViewControllerTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 6.08.25.
//

import XCTest
@testable import FilmsReview

private class SpySignUpInteractor: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var registerCalled = false
    var lastEmail: String?
    var lastPassword: String?

    func register(email: String, password: String) {
        registerCalled = true
        lastEmail = email
        lastPassword = password
    }

    func login(email: String, password: String) {}
    func signOut(completion: @escaping (Error?) -> Void) {}
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {}
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void) {}
    func startEmailVerificationMonitoring() {}
    func stopEmailVerificationMonitoring() {}
    func deleteAccount(completion: @escaping (Error?) -> Void) {}
    func validateEmail(_ email: String) -> Bool { true }
    func resetPassword(email: String) {}
    func createProfile(name: String, birthday: Date, avatarData: Data?) {}
    
    func saveFavoriteGenres(_ genres: [String]) {}
    func fetchTMDBGenres(language: String) {}
}

private class SpySignUpRouter: AuthenticationRouterProtocol {
    weak var viewController: ViewControllerProtocol?
    private(set) var navigateToLoginCalled = false

    func navigateToLogin() { navigateToLoginCalled = true }
    func navigateToSignUp() {}
    func routeToEmailVerification() {}
    func navigateToForgotPassword() {}
    func navigateToCheckYourEmail(email: String) {}
    func navigateToCreateProfile() {}
    func navigateToChooseInterests() {}
}

final class SignUpViewControllerTests: XCTestCase {
    private var vc: SignUpViewController!
    private var interactor: SpySignUpInteractor!
    private var router: SpySignUpRouter!

    override func setUp() {
        super.setUp()
        vc = SignUpViewController()
        interactor = SpySignUpInteractor()
        router = SpySignUpRouter()
        vc.interactor = interactor
        vc.router = router
        vc.loadViewIfNeeded()
    }

    override func tearDown() {
        vc = nil
        interactor = nil
        router = nil
        super.tearDown()
    }
    
    private func allTextFields() -> [UITextField] {
        func rec(_ v: UIView) -> [UIView] {
            return v.subviews + v.subviews.flatMap(rec)
        }
        return rec(vc.view).compactMap { $0 as? UITextField }
    }

    private var emailField: UITextField {
        return allTextFields().first { $0.placeholder == "Email" }!
    }
    private var passwordField: UITextField {
        return allTextFields().first { $0.isSecureTextEntry }!
    }
    private var confirmField: UITextField {
        return allTextFields().filter { $0.isSecureTextEntry }.last!
    }
    private var createButton: UIButton {
        return vc.view.subviews
            .flatMap { [$0] + $0.subviews }
            .compactMap { $0 as? UIButton }
            .first { $0.title(for: .normal) == "Create a new account" }!
    }
    private var loginButton: UIButton {
        return vc.view.subviews
            .flatMap { [$0] + $0.subviews }
            .compactMap { $0 as? UIButton }
            .first { $0.title(for: .normal) == "Do you already have an account?" }!
    }

    func testCreateAccountEmptyFieldsDoesNotCallRegister() {
        vc.createAccount()
        XCTAssertFalse(interactor.registerCalled,
                      "При пустых полях register(email:password:) не должен вызываться")
    }

    func testCreateAccountMismatchedPasswordsDoesNotCallRegister() {
        emailField.text = "user@example.com"
        passwordField.text = "Pass1!"
        confirmField.text = "Other1!"
        vc.createAccount()
        XCTAssertFalse(interactor.registerCalled,
                      "При несовпадающих паролях register(email:password:) не должен вызываться")
    }

    func testCreateAccountValidFieldsCallsRegister() {
        emailField.text = "user@example.com"
        passwordField.text = "Secret1!"
        confirmField.text = "Secret1!"
        vc.createAccount()
        XCTAssertTrue(interactor.registerCalled,
                      "Для валидных полей должен вызваться register(email:password:)")
        XCTAssertEqual(interactor.lastEmail, "user@example.com")
        XCTAssertEqual(interactor.lastPassword, "Secret1!")
    }

    func testLoginTappedNavigatesToLogin() {
        loginButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(router.navigateToLoginCalled,
                      "При нажатии кнопки перехода к логину должен вызываться router.navigateToLogin()")
    }
}
