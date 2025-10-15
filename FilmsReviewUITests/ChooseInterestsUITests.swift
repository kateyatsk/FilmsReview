//
//  ChooseInterestsUITests.swift
//  FilmsReviewUITests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest

final class ChooseInterestsUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UITesting_ChooseInterests"] = "1"
        app.launch()
    }
    
    func testOpensChooseInterestsScreen() {
        let search = app.searchFields["Search..."]
        XCTAssertTrue(search.waitForExistence(timeout: 5), "Поле поиска должно существовать")
        
        let collection = app.collectionViews.firstMatch
        XCTAssertTrue(collection.exists, "Коллекция должна существовать")
        
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists, "Кнопка должна существовать")
    }
    
    func testSearchFiltersResults() {
        let search = app.searchFields["Search..."]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("dr")
        
        let dramaButton = app.buttons["Drama"]
        XCTAssertTrue(dramaButton.waitForExistence(timeout: 2), "Должна остаться ячейка Drama")
      
        XCTAssertEqual(visibleCells().count, 1, "После фильтра должен остаться 1 элемент")
    }
    
    func testClearSearchShowsAllAgain() {
        let search = app.searchFields["Search..."]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("xyz")
        
        XCTAssertEqual(visibleCells().count, 0, "Неверный запрос должен скрыть все элементы")
        
        clear(searchField: search)
        XCTAssertGreaterThan(visibleCells().count, 0, "После очистки должны снова появиться элементы")
    }
    
    func testSearchIsCaseInsensitive() {
        let search = app.searchFields["Search..."]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("DR")
        
        let dramaButton = app.buttons["Drama"]
        XCTAssertTrue(dramaButton.waitForExistence(timeout: 2), "Должна находиться Drama по запросу 'DR'")
    }
    
  
    func testSelectOneItemAndTapNext() {
        let drama = app.buttons["Drama"]
        XCTAssertTrue(drama.waitForExistence(timeout: 5))
        drama.tap()
        
        let next = app.buttons["Next"]
        XCTAssertTrue(next.exists)
        next.tap()
    }

    func testSelectMultipleItemsAndTapNext() {
        let action = app.buttons["Action"]
        let comedy = app.buttons["Comedy"]
        
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        XCTAssertTrue(comedy.waitForExistence(timeout: 5))
        
        action.tap()
        comedy.tap()
        
        app.buttons["Next"].tap()
    }

    
    private func visibleCells() -> XCUIElementQuery {
        app.collectionViews.firstMatch.cells
    }
    
    private func clear(searchField: XCUIElement) {
        guard let value = searchField.value as? String, value.isEmpty == false else { return }
        searchField.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
        searchField.typeText(deleteString)
    }
}
