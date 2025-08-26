//
//  LoginViewControllerTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 6.08.25.
//

import XCTest
@testable import FilmsReview

private class SpyLoginInteractor: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    
    var loginCalled = false
    var loginEmail: String?
    var loginPassword: String?

    func login(email: String, password: String) {
        loginCalled = true
        loginEmail = email
        loginPassword = password
    }

    func register(email: String, password: String) {}
    func signOut(completion: @escaping (Error?) -> Void) {}
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {}
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void) {}
    func startEmailVerificationMonitoring() {}
    func stopEmailVerificationMonitoring() {}
    func deleteAccount(completion: @escaping (Error?) -> Void) {}
    func validateEmail(_ email: String) -> Bool { true }
    func resetPassword(email: String) {}
    func createProfile(name: String, birthday: Date, avatarData: Data?) {}
}

private class SpyLoginRouter: AuthenticationRouterProtocol {
    weak var viewController: ViewControllerProtocol?
    private(set) var navigateToForgotPasswordCalled = false
    private(set) var navigateToSignUpCalled = false

    func navigateToLogin() {}
    func navigateToSignUp() { navigateToSignUpCalled = true }
    func routeToEmailVerification() {}
    func navigateToForgotPassword() { navigateToForgotPasswordCalled = true }
    func navigateToCheckYourEmail(email: String) {}
    func navigateToCreateProfile() {}
}


final class LoginViewControllerTests: XCTestCase {
    private var vc: LoginViewController!
    private var interactor: SpyLoginInteractor!
    private var router: SpyLoginRouter!

    override func setUp() {
        super.setUp()
        vc = LoginViewController()
        interactor = SpyLoginInteractor()
        router = SpyLoginRouter()
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

    private func allSubviews(of view: UIView) -> [UIView] {
        return view.subviews + view.subviews.flatMap { allSubviews(of: $0) }
    }

    private func textField(placeholder: String) -> UITextField {
        let all = allSubviews(of: vc.view).compactMap { $0 as? UITextField }
        guard let tf = all.first(where: { $0.placeholder == placeholder }) else {
            XCTFail("Не найден UITextField с placeholder «\(placeholder)»")
            return UITextField()
        }
        return tf
    }

    private func secureField() -> UITextField {
        let all = allSubviews(of: vc.view).compactMap { $0 as? UITextField }
        guard let tf = all.first(where: { $0.isSecureTextEntry }) else {
            XCTFail("Не найден Secure UITextField")
            return UITextField()
        }
        return tf
    }

    private func button(title: String) -> UIButton {
        let all = allSubviews(of: vc.view).compactMap { $0 as? UIButton }
        guard let btn = all.first(where: { $0.title(for: .normal) == title }) else {
            XCTFail("Не найден UIButton с title «\(title)»")
            return UIButton()
        }
        return btn
    }

    func testSignInTappedWithEmptyFieldsShowsErrorAndDoesNotCallInteractor() {
         let email = textField(placeholder: "Email")
         let pass  = secureField()

         email.text = ""
         pass.text  = ""

         let loginBtn = button(title: "LOG IN")
         loginBtn.sendActions(for: .touchUpInside)
        
         XCTAssertFalse(
             interactor.loginCalled,
             "interactor.login не должен вызываться при пустых полях"
         )

         XCTAssertNil(
             vc.presentedViewController,
             "При пустых полях не должно быть UIAlertController, т.к. кнопка неактивна"
         )
    }

    func testSignInTappedWithValidFieldsCallsInteractorAndDisablesButton() {
        let email = textField(placeholder: "Email")
        let pass  = secureField()
        email.text = "user@example.com"
        pass.text  = "Password1!"

        vc.perform(Selector(("signInTapped")))

        XCTAssertTrue(
            interactor.loginCalled,
            "interactor.login должен вызываться при валидных полях"
        )
        XCTAssertEqual(interactor.loginEmail, "user@example.com")
        XCTAssertEqual(interactor.loginPassword, "Password1!")

        let loginBtn = button(title: "LOG IN")
        XCTAssertFalse(
            loginBtn.isEnabled,
            "Кнопка должна отключиться сразу после начала запроса"
        )
    }

    func testFinishSubmittingReenablesButton() {
        let loginBtn = button(title: "LOG IN")
        loginBtn.isEnabled = false
        vc.finishSubmitting()
        XCTAssertTrue(
            loginBtn.isEnabled,
            "finishSubmitting() должен вновь включать кнопку"
        )
    }

    func testTogglePasswordVisibilityTogglesSecureEntry() {
        let pass = secureField()
        XCTAssertTrue(pass.isSecureTextEntry, "Пароль изначально скрыт")
        vc.perform(Selector(("togglePasswordVisibility")))
        XCTAssertFalse(pass.isSecureTextEntry, "После первого toggle пароль виден")
        vc.perform(Selector(("togglePasswordVisibility")))
        XCTAssertTrue(pass.isSecureTextEntry, "После второго toggle пароль снова скрыт")
    }

    func testForgotPasswordCallsRouter() {
        vc.perform(Selector(("showForgotPasswordScreen")))
        XCTAssertTrue(
            router.navigateToForgotPasswordCalled,
            "При нажатии 'Forgot password?' должен вызываться router.navigateToForgotPassword()"
        )
    }

    func testSignUpCallsRouter() {
        vc.perform(Selector(("signUpTapped")))
        XCTAssertTrue(
            router.navigateToSignUpCalled,
            "При нажатии 'Don't you have an account yet?' должен вызываться router.navigateToSignUp()"
        )
    }

    func testReturnKeyFlow() {
        let emailField = textField(placeholder: "Email")
        emailField.text = ""
        
        let handledEmail = vc.textFieldShouldReturn(emailField)
        XCTAssertTrue(handledEmail, "textFieldShouldReturn должен возвращать true для emailField")
        XCTAssertNil(
            vc.presentedViewController,
            "При Return в emailField не должно быть UIAlertController"
        )
        
        let passwordField = secureField()
        passwordField.text = ""
        
        let handledPassword = vc.textFieldShouldReturn(passwordField)
        XCTAssertTrue(handledPassword, "textFieldShouldReturn должен возвращать true для passwordField")
        
    }
}
