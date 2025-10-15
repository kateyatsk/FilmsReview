//
//  FilmsReviewUITests.swift
//  FilmsReviewUITests
//
//  Created by Екатерина Яцкевич on 23.06.25.
//

import XCTest

final class OnboardingUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        app.launchEnvironment["UITesting_ResetOnboarding"] = "1"
        
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testSkipOnFirstPageGoesToHome() throws {
        let skipButton = app.buttons["Skip"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 2), "Кнопка Skip не появилась")
        skipButton.tap()

        let hello = app.staticTexts["Explore the world of films!"]
        XCTAssertTrue(hello.waitForExistence(timeout: 5), "Главный экран не открылся")
    }

    func testSwipeThroughSlidesShowsGetStartedOnLast() throws {
        let expectedSlides = 3

        let pageIndicator = app.pageIndicators.firstMatch
        XCTAssertTrue(pageIndicator.waitForExistence(timeout: 4))

        XCTAssertEqual(pageIndicator.value as? String, "page 1 of \(expectedSlides)")

        for _ in 1..<expectedSlides {
            app.swipeLeft()
        }

        XCTAssertEqual(pageIndicator.value as? String, "page \(expectedSlides) of \(expectedSlides)",
                       "Не дошли до последнего слайда")

        XCTAssertFalse(app.buttons["Skip"].exists,
                       "На последнем слайде кнопка Skip не должна отображаться")

        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.exists && getStarted.isHittable,
                      "Кнопка Get Started не появилась на последнем слайде")
    }

    func testGetStartedCompletesOnboarding() throws {
        let expectedSlides = 3
        for _ in 1..<expectedSlides {
            app.swipeLeft()
        }

        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 2))
        getStarted.tap()

        let hello = app.staticTexts["Explore the world of films!"]
        XCTAssertTrue(hello.waitForExistence(timeout: 5),
                      "После Get Started не открывается главный экран")
    }
}
