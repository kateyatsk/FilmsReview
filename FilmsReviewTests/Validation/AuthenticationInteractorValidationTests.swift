//
//  AuthenticationInteractorValidationTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 30.07.25.
//

import XCTest
@testable import FilmsReview

final class MockAuthWorker: AuthenticationWorkerProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<FilmsReview.User, any Error>) -> Void) {}
    func signIn(email: String, password: String, completion: @escaping (Result<FilmsReview.User, any Error>) -> Void) {}
    func signOut(completion: @escaping ((any Error)?) -> Void) {}
    
    func isUserLoggedIn() -> Bool {return false}
    func isEmailVerified() -> Bool {return false}
    func sendVerificationEmail(completion: @escaping ((any Error)?) -> Void) {}
    func reloadUser(completion: @escaping ((any Error)?) -> Void) {}
    func deleteUser(completion: @escaping ((any Error)?) -> Void) {}

}

final class AuthenticationInteractorValidationTests: XCTestCase {
    var sut: AuthenticationInteractor!

    override func setUp() {
        super.setUp()
        sut = AuthenticationInteractor(worker: MockAuthWorker())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testValidEmails() {
        let validEmails = [
            "test@example.com",
            "user.name+tag+sorting@example.co.uk",
            "user_name@example.org",
            "user-name@example.io"
        ]

        for email in validEmails {
            XCTAssertTrue(sut.validateEmail(email), "Email \(email) должен быть валиден")
        }
    }

    func testInvalidEmails() {
        let invalidEmails = [
            "",
            "plainaddress",
            "@missingusername.com",
            "user@.com"
        ]

        for email in invalidEmails {
            XCTAssertFalse(sut.validateEmail(email), "Email \(email) не должен быть валиден")
        }
    }
}
