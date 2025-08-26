//
//  AuthenticationUITests.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 6.08.25.
//

import XCTest

final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!

    private var testEmail: String {
        let ts = Int(Date().timeIntervalSince1970)
        return "uitest\(ts)@mail.com"
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func focus(_ field: XCUIElement) {
        field.tap()
        let center = field.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 2),
                      "Клавиатура не появилась после тапа")
    }

    private func openSignUp() {
        let btn = app.buttons["Create a new account"]
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Кнопка Sign Up не найдена")
        btn.tap()
    }

    private func openLogin() {
        let btn = app.buttons["LOG IN"]
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Кнопка LOG IN не найдена")
        btn.tap()
    }

    func testSignUpWithInvalidEmailShowsError() {
        openSignUp()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("not-an-email")

        let secure = app.secureTextFields.allElementsBoundByIndex.filter { $0.isHittable }
        focus(secure[0]); secure[0].typeText("Qwerty1!")
        focus(secure[1]); secure[1].typeText("Qwerty1!")

        app.buttons["Create a new account"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2),
                      "Должен показать ошибку про некорректный e-mail")
    }

    func testSignUpWithMismatchedPasswordsShowsError() {
        openSignUp()

        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText(testEmail)

        let secure = app.secureTextFields.allElementsBoundByIndex.filter { $0.isHittable }
        focus(secure[0]); secure[0].typeText("Qwerty1!")
        focus(secure[1]); secure[1].typeText("Another1!")

        app.buttons["Create a new account"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2),
                      "Должен показать ошибку про несовпадение паролей")
    }

    func testSignUpHappyPathShowsEmailConfirmation() {
        openSignUp()

        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText(testEmail)

        let secure = app.secureTextFields.allElementsBoundByIndex.filter { $0.isHittable }
        focus(secure[0]); secure[0].typeText("Qwerty1!")
        focus(secure[1]); secure[1].typeText("Qwerty1!")

        let create = app.buttons["Create a new account"]
        expectation(
            for: NSPredicate(format: "isEnabled == true"),
            evaluatedWith: create, handler: nil
        )
        waitForExpectations(timeout: 5)
        create.tap()

        let confirmTitle = app.staticTexts["Email Confirmation"]
        XCTAssertTrue(confirmTitle.waitForExistence(timeout: 5),
                      "После регистрации должен показаться экран подтверждения почты")
    }

    func testLoginWithEmptyFieldsShowsError() {
        openLogin()
        app.buttons["LOG IN"].tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2),
                      "Должен появиться алерт о том, что все поля обязательны")
    }

    func testForgotPasswordNavigation() {
        openLogin()

        let forgotBtn = app.buttons["Forgot password?"]
        XCTAssertTrue(forgotBtn.exists, "Кнопка 'Forgot password?' не найдена")
        forgotBtn.tap()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5),
                      "Поле Email на экране Forgot Password не появилось")

        emailField.tap()
        emailField.typeText(testEmail)
        app.buttons["Continue"].tap()

        let checkButton = app.buttons["Back to Login"]
        XCTAssertTrue(checkButton.waitForExistence(timeout: 5),
                      "После Continue должен появиться кнопка назад")
    }

    func testPasswordValidationTagsAppear() {
        openSignUp()
        let secure = app.secureTextFields.allElementsBoundByIndex.filter { $0.isHittable }
        focus(secure[0])
        secure[0].typeText("123")
        XCTAssertTrue(app.staticTexts["6+ characters"].exists,
                      "Должен появиться тег правила «6+ characters» при вводе слабого пароля")
    }
}
