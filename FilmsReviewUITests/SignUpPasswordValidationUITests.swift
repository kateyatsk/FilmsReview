//
//  SignUpPasswordValidationUITests.swift
//  FilmsReviewUITests
//
//  Created by Екатерина Яцкевич on 31.07.25.
//

import XCTest

final class SignUpPasswordValidationUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITesting_SkipOnboarding"] = "1"
        app.launch()
        navigateToSignUp()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    func testAllValidationTagsInitiallyInvalid() {
        let tags = app.collectionViews.cells
        XCTAssertEqual(tags.count, 7, "Должно быть 7 правил валидации")
        
        for i in 0..<tags.count {
            let cell = tags.element(boundBy: i)
            let icon = cell.images.element
            XCTAssertTrue(icon.exists, "У тега \(i) должна быть иконка")
            XCTAssertEqual(icon.identifier, "xmark.circle.fill", "Изначально тег \(i) должен быть невалидным (крестик)")
        }
    }
    
    func testAllValidationTagsBecomeValidWithStrongPassword() {
        let passwordField = app.secureTextFields.element(boundBy: 0)
        passwordField.tap()
        passwordField.typeText("Aa1!abcd")
        
        let tags = app.collectionViews.cells
        XCTAssertEqual(tags.count, 7, "Должно быть 7 правил валидации")
        
        for i in 0..<tags.count {
            let icon = tags.element(boundBy: i).images.element
            XCTAssertTrue(icon.exists, "У тега \(i) должна быть иконка")
            XCTAssertEqual(icon.identifier, "checkmark.circle.fill", "Иконка тега \(i) должна быть галочкой")
        }
    }
    
    func testShortPasswordInvalidatesMinLengthRule() {
        typePassword("Aa1!")
        assertRule("6+ characters", icon: "xmark.circle.fill")
    }
    
    func testPasswordWithoutDigitInvalidatesDigitRule() {
        typePassword("Aa!aaaa")
        assertRule("1+ digit", icon: "xmark.circle.fill")
    }
    
    func testPasswordWithoutUppercaseInvalidatesUppercaseRule() {
        typePassword("aa1!aaaa")
        assertRule("1+ uppercase", icon: "xmark.circle.fill")
    }
    
    func testWhitespaceInPasswordInvalidatesWhitespaceRule() {
        typePassword("Aa1! aaaa")
        assertRule("No whitespaces", icon: "xmark.circle.fill")
    }
    
    func testPasswordWithoutLowercaseInvalidatesLowercaseRule() {
        typePassword("AA1!AAAA")
        assertRule("1+ lowercase", icon: "xmark.circle.fill")
    }
    
    func testPasswordWithoutSpecialCharInvalidatesSpecialCharRule() {
        typePassword("Aa1aaaaa")
        assertRule("1+ special char", icon: "xmark.circle.fill")
    }
    
    func testNonLatinCharactersInvalidateOnlyLatinRule() {
        typePassword("Aa1![]")
        assertRule("Only Latin letters", icon: "xmark.circle.fill")
    }
    
    func testCreateAccountButtonEnabledOnlyWhenPasswordValid() {
        let button = app.buttons.matching(identifier: "Create a new account").firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 3), "Кнопка 'Create a new account' не найдена")
        XCTAssertFalse(button.isEnabled, "Кнопка должна быть неактивной до ввода валидного пароля")
        
        typePassword("Aa1!abcd")
        
        XCTAssertTrue(button.isEnabled, "Кнопка должна стать активной при валидном пароле")
    }
    
    func testInvalidEmailShowsErrorMessage() {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2), "Поле e‑mail не найдено")
        
        emailField.tap()
        emailField.typeText("invalidemail")
        
        let passwordField = app.secureTextFields.element(boundBy: 0)
        passwordField.tap()
        
        let errorLabel = app.staticTexts["Please enter a valid email address."]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2), "Ошибка 'Please enter a valid email address.' должна отображаться для невалидного e‑mail")
    }
    
    private func typePassword(_ text: String) {
        let passwordField = app.secureTextFields.element(boundBy: 0)
        passwordField.tap()
        passwordField.typeText(text)
    }
    
    private func assertRule(_ rule: String, icon: String) {
        let cell = app.collectionViews.cells.containing(.staticText, identifier: rule).element
        XCTAssertTrue(cell.exists, "Ячейка правила '\(rule)' должна существовать")
        let image = cell.images.element
        XCTAssertTrue(image.exists, "У правила '\(rule)' должна быть иконка")
        XCTAssertEqual(image.identifier, icon, "У правила '\(rule)' должна быть иконка \(icon)")
    }
    
    private func navigateToSignUp() {
        let signUpButton = app.buttons["Create a new account"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 3), "Кнопка Sign Up не найдена")
        signUpButton.tap()
    }
}
