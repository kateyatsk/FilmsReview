//
//  AuthenticationInteractorChooseInterestsTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest
@testable import FilmsReview

final class AuthenticationInteractorChooseInterestsTests: XCTestCase {
    private var sut: AuthenticationInteractor!
    private var worker: AuthWorkerStub!
    private var presenter: ChooseInterestsPresenterSpy!

    override func setUp() {
        super.setUp()
        worker = AuthWorkerStub()
        presenter = ChooseInterestsPresenterSpy()
        sut = AuthenticationInteractor(presenter: presenter, worker: worker)
    }

    override func tearDown() {
        sut = nil
        worker = nil
        presenter = nil
        super.tearDown()
    }

    func testFetchTmdbGenresSuccessFlowsThrough() {
        worker.stubbedGenres = ["Action", "Drama"]

        let didLoad = expectation(description: "didLoadGenres called")
        presenter.onDidLoadGenres = { names in
            XCTAssertEqual(names, ["Action", "Drama"])
            didLoad.fulfill()
        }

        sut.fetchTMDBGenres(language: "en-EN")

        XCTAssertTrue(presenter.didStartLoadingGenresCalled)

        wait(for: [didLoad], timeout: 1.0)
        XCTAssertNil(presenter.failedLoadingGenresError)
    }

    func testFetchTmdbGenresFailureFlowsThrough() {
        worker.stubbedError = TestError.any

        let didFail = expectation(description: "didFailLoadingGenres called")
        presenter.onDidFailLoadingGenres = { _ in
            didFail.fulfill()
        }

        sut.fetchTMDBGenres(language: "en-EN")

        XCTAssertTrue(presenter.didStartLoadingGenresCalled)
        wait(for: [didFail], timeout: 1.0)
        XCTAssertTrue(presenter.loadedGenres.isEmpty)
        XCTAssertNotNil(presenter.failedLoadingGenresError)
    }

    func testSaveFavoriteGenresWhenNoUidFailsImmediately() {
        worker.currentUID = nil

        sut.saveFavoriteGenres(["Action"])

        XCTAssertTrue(presenter.didStartSavingFavoriteGenresCalled)
        XCTAssertFalse(presenter.didSaveFavoriteGenresCalled)
        XCTAssertNotNil(presenter.failedSavingFavoriteGenresError)
    }

    func testSaveFavoriteGenresSuccessCallsDidSave() {
        worker.currentUID = "uid-1"
        worker.updateUserResult = .success(())

        let didSave = expectation(description: "didSaveFavoriteGenres called")
        presenter.onDidSaveFavoriteGenres = {
            didSave.fulfill()
        }

        sut.saveFavoriteGenres(["Action", "Drama"])

        XCTAssertTrue(presenter.didStartSavingFavoriteGenresCalled)
        wait(for: [didSave], timeout: 1.0)
        XCTAssertNil(presenter.failedSavingFavoriteGenresError)
    }

    func testSaveFavoriteGenresFailureCallsDidFail() {
        worker.currentUID = "uid-1"
        worker.updateUserResult = .failure(TestError.any)

        let didFail = expectation(description: "didFailSavingFavoriteGenres called")
        presenter.onDidFailSavingFavoriteGenres = { _ in
            didFail.fulfill()
        }

        sut.saveFavoriteGenres(["Action"])

        XCTAssertTrue(presenter.didStartSavingFavoriteGenresCalled)
        wait(for: [didFail], timeout: 1.0)
        XCTAssertFalse(presenter.didSaveFavoriteGenresCalled)
        XCTAssertNotNil(presenter.failedSavingFavoriteGenresError)
    }
}

private enum TestError: Error { case any }

private final class ChooseInterestsPresenterSpy: AuthenticationPresenterProtocol {
    var viewController: ViewControllerProtocol?

    var onDidLoadGenres: (([String]) -> Void)?
    var onDidFailLoadingGenres: ((Error) -> Void)?
    var onDidSaveFavoriteGenres: (() -> Void)?
    var onDidFailSavingFavoriteGenres: ((Error) -> Void)?

    var didStartLoadingGenresCalled = false
    var loadedGenres: [String] = []
    var failedLoadingGenresError: Error?

    var didStartSavingFavoriteGenresCalled = false
    var didSaveFavoriteGenresCalled = false
    var failedSavingFavoriteGenresError: Error?

    func didRegister(user: User) {}
    func didLogin(user: User) {}
    func didFail(error: Error) {}
    func didConfirmEmail() {}
    func didResetPassword() {}
    func didCreateProfile() {}

    func didStartLoadingGenres() { didStartLoadingGenresCalled = true }

    func didLoadGenres(names: [String]) {
        loadedGenres = names
        onDidLoadGenres?(names)
    }

    func didFailLoadingGenres(error: Error) {
        failedLoadingGenresError = error
        onDidFailLoadingGenres?(error)
    }

    func didStartSavingFavoriteGenres() { didStartSavingFavoriteGenresCalled = true }

    func didSaveFavoriteGenres() {
        didSaveFavoriteGenresCalled = true
        onDidSaveFavoriteGenres?()
    }

    func didFailSavingFavoriteGenres(error: Error) {
        failedSavingFavoriteGenresError = error
        onDidFailSavingFavoriteGenres?(error)
    }
}

private final class AuthWorkerStub: AuthenticationWorkerProtocol {
    var stubbedGenres: [String] = []
    var stubbedError: Error?
    var currentUID: String? = "uid-1"
    var updateUserResult: Result<Void, Error> = .success(())

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func signOut(completion: @escaping (Error?) -> Void) { completion(nil) }
    func isUserLoggedIn() -> Bool { true }
    func isEmailVerified() -> Bool { true }
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) { completion(nil) }
    func reloadUser(completion: @escaping (Error?) -> Void) { completion(nil) }
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) { completion(nil) }
    func deleteUser(completion: @escaping (Error?) -> Void) { completion(nil) }
    func getCurrentUserEmail() -> String? { "test@email.com" }
    func getCurrentUserID() -> String? { currentUID }

    func uploadAvatar(data: Data?, userId: String, completion: @escaping (Result<URL?, Error>) -> Void) {
        completion(.success(nil))
    }

    func saveUserProfileToFirestore(uid: String,
                                    email: String,
                                    name: String,
                                    birthday: Date,
                                    avatarURL: URL?,
                                    completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func updateUser(uid: String, fields: [String : Any], completion: @escaping (Result<Void, Error>) -> Void) {
        completion(updateUserResult)
    }

    func fetchTMDBGenresMerged(language: String, completion: @escaping (Result<[String], Error>) -> Void) {
        if let err = stubbedError {
            completion(.failure(err))
        } else {
            completion(.success(stubbedGenres))
        }
    }
}
