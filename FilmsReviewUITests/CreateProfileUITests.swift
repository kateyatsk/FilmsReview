//
//  CreateProfileUITests.swift
//  FilmsReviewUITests
//
//  Created by Екатерина Яцкевич on 8.08.25.
//

import XCTest

final class CreateProfileUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchEnvironment["UITesting_CreateProfileScreen"] = "1"
        app.launch()
    }

    func testCreateProfileSuccess() {
        let nameField = app.textFields["Enter name"]
        let birthdayField = app.textFields["MM/DD/YYYY"]
        let createButton = app.buttons["Create Profile"]

        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        XCTAssertTrue(birthdayField.exists)
        XCTAssertTrue(createButton.exists)

        nameField.tap()
        nameField.typeText("UITestUser")

        birthdayField.tap()
        let doneButton = app.toolbars.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        doneButton.tap()

        createButton.tap()
    }

    func testCreateProfileFailsIfNameEmpty() {
        let birthdayField = app.textFields["MM/DD/YYYY"]
        let createButton = app.buttons["Create Profile"]

        XCTAssertTrue(birthdayField.waitForExistence(timeout: 2))

        birthdayField.tap()
        app.toolbars.buttons["Done"].tap()
        createButton.tap()

        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        XCTAssertTrue(alert.staticTexts["Name cannot be empty"].exists)
    }

    func testBirthdayPickerShowsToolbar() {
        let birthdayField = app.textFields["MM/DD/YYYY"]
        birthdayField.tap()

        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists)

        let toolbar = app.toolbars.element
        XCTAssertTrue(toolbar.exists)

        let doneButton = toolbar.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
    }

    func testAvatarImageViewIsTappable() {
        let avatar = app.images["person.circle.fill"]
        XCTAssertTrue(avatar.exists)
        avatar.tap()

        let alert = app.alerts.firstMatch
        if alert.exists {
            alert.buttons["Allow Access to All Photos"].tap()
        }
    }
}
