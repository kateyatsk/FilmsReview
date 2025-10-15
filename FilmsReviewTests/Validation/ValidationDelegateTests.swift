//
//  ValidationDelegateTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 30.07.25.
//

import XCTest
@testable import FilmsReview

final class ValidationDelegateTests: XCTestCase {
    var sut: ValidationDelegate!
    
    override func setUp() {
        super.setUp()
        let rules: [ValidationRule] = [
            ValidationRule(message: "No whitespaces", regex: ValidationRegex.noWhitespaces.rawValue),
            ValidationRule(message: "Has digit", regex: ValidationRegex.hasDigit.rawValue),
            ValidationRule(message: "Only Latin letters", regex: ValidationRegex.onlyLatin.rawValue),
            ValidationRule(message: "Min length", regex: ValidationRegex.minLength.rawValue),
            ValidationRule(message: "Has lowercase", regex: ValidationRegex.hasLowercase.rawValue),
            ValidationRule(message: "Has uppercase", regex: ValidationRegex.hasUppercase.rawValue),
            ValidationRule(message: "Has special char", regex: ValidationRegex.hasSpecialChar.rawValue)
        ]
        sut = ValidationDelegate(rules: rules)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAllRulesFailForEmptyPassword() {
        sut.checkValidationTags(text: "") {}
        XCTAssertTrue(sut.rulesState.values.allSatisfy { !$0 }, "Все правила должны быть невалидны для пустой строки")
    }
    
    func testPasswordThatMeetsAllRules() {
        let strongPassword = "Aa1!abcd"
        sut.checkValidationTags(text: strongPassword) {}
        XCTAssertTrue(sut.rulesState.values.allSatisfy { $0 }, "Все правила должны быть выполнены для \(strongPassword)")
    }
    
    func testPasswordShorterThanMinLengthFailsMinLengthRule() {
        sut.checkValidationTags(text: "Aa1!") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Min length" }?.value ?? true,
                       "Короткий пароль должен провалить правило Min length")
    }
    
    func testPasswordWithExactlySixCharactersPassesMinLengthRule() {
        sut.checkValidationTags(text: "Aa1!bc") {}
        XCTAssertTrue(sut.rulesState.first { $0.key.message == "Min length" }?.value ?? false,
                      "Пароль ровно из 6 символов должен проходить правило Min length")
    }
    
    func testPasswordWithoutDigitFailsDigitRule() {
        sut.checkValidationTags(text: "Aa!aaaa") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has digit" }?.value ?? true,
                       "Пароль без цифр должен провалить правило Has digit")
    }
    
    func testPasswordWithoutUppercaseFailsUppercaseRule() {
        sut.checkValidationTags(text: "aa1!aaaa") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has uppercase" }?.value ?? true,
                       "Пароль без заглавных букв должен провалить правило Has uppercase")
    }
    
    func testPasswordWithoutLowercaseFailsLowercaseRule() {
        sut.checkValidationTags(text: "AA1!AAAA") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has lowercase" }?.value ?? true,
                       "Пароль без строчных букв должен провалить правило Has lowercase")
    }
    
    func testPasswordWithoutSpecialCharFailsSpecialCharRule() {
        sut.checkValidationTags(text: "Aa1aaaaa") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has special char" }?.value ?? true,
                       "Пароль без спецсимволов должен провалить правило Has special char")
    }
    
    func testPasswordWithWhitespaceFailsNoWhitespacesRule() {
        sut.checkValidationTags(text: "Aa1! aaaa") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "No whitespaces" }?.value ?? true,
                       "Пробел должен провалить правило No whitespaces")
    }
    
    func testPasswordWithNonLatinFailsOnlyLatinRule() {
        sut.checkValidationTags(text: "Aa1!тест") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Only Latin letters" }?.value ?? true,
                       "Нелатинские буквы должны провалить правило Only Latin letters")
    }
    
    func testPasswordWithMultipleViolationsFailsMultipleRules() {
        sut.checkValidationTags(text: "12345") {}
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has uppercase" }?.value ?? true,
                       "Пароль без заглавных букв должен провалить правило Has uppercase")
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has lowercase" }?.value ?? true,
                       "Пароль без строчных букв должен провалить правило Has lowercase")
        XCTAssertFalse(sut.rulesState.first { $0.key.message == "Has special char" }?.value ?? true,
                       "Пароль без спецсимволов должен провалить правило Has special char")
    }
}

