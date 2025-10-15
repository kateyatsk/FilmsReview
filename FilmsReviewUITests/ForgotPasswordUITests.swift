//
//  ForgotPasswordUITests.swift
//  FilmsReviewUITests
//
//  Created by Екатерина Яцкевич on 30.07.25.
//

import XCTest

final class ForgotPasswordUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITesting_SkipOnboarding"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testEmptyEmailShowsAlert() {
        navigateToForgotPassword()

        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2), "Кнопка Continue не найдена")
        continueButton.tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Алерт не появился")
        XCTAssertTrue(alert.staticTexts["Enter your email"].exists, "Сообщение в алерте некорректное")
    }

    func testInvalidEmailShowsAlert() {
        navigateToForgotPassword()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2), "Поле Email не найдено")
        emailField.tap()
        emailField.typeText("bad_email")

        let continueButton = app.buttons["Continue"]
        continueButton.tap()

        let alert = app.alerts["Error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Алерт с ошибкой не появился")
        XCTAssertTrue(alert.staticTexts["The email address is badly formatted."].exists, "Текст ошибки некорректный")
    }

    func testValidEmailNavigatesToCheckEmailScreen() {
        navigateToForgotPassword()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2), "Поле Email не найдено")
        emailField.tap()
        emailField.typeText("test@example.com")

        let continueButton = app.buttons["Continue"]
        continueButton.tap()

        let checkEmailText = app.staticTexts["If this email exists, we sent you a password reset link to test@example.com.\n\nPlease check your inbox."]
        XCTAssertTrue(checkEmailText.waitForExistence(timeout: 5), "Экран Check your email не открылся")
    }

    func testBackToLoginFromCheckEmail() {
        navigateToForgotPassword()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2), "Поле Email не найдено")
        emailField.tap()
        emailField.typeText("test@example.com")
        app.buttons["Continue"].tap()

        let backButton = app.buttons["Back to Login"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Кнопка Back to Login не найдена")
        backButton.tap()

        XCTAssertTrue(app.buttons["LOG IN"].waitForExistence(timeout: 3), "Не вернулись на экран логина")
    }

    private func navigateToForgotPassword() {
        let loginButton = app.buttons["LOG IN"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 3), "Кнопка Login не найдена")
        loginButton.tap()

        let forgotButton = app.buttons["Forgot password?"]
        XCTAssertTrue(forgotButton.waitForExistence(timeout: 3), "Кнопка Forgot password? не найдена")
        forgotButton.tap()
    }
}
