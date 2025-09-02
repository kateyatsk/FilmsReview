//
//  AuthInteractorTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 7.08.25.
//

import XCTest
@testable import FilmsReview

class AuthenticationWorkerMock: AuthenticationWorkerProtocol {
    var getCurrentUserIDStub: String? = "test-uid"
    var getCurrentUserEmailStub: String? = "test@mail.com"
    
    var uploadAvatarCalled = false
    var saveProfileCalled = false
    
    func getCurrentUserID() -> String? { getCurrentUserIDStub }
    func getCurrentUserEmail() -> String? { getCurrentUserEmailStub }
    
    func uploadAvatar(data: Data?, userId: String, completion: @escaping (Result<URL?, Error>) -> Void) {
        uploadAvatarCalled = true
        completion(.success(URL(string: "https://fake.url/avatar.jpg")))
    }
    
    func saveUserProfileToFirestore(uid: String, email: String, name: String, birthday: Date, avatarURL: URL?, completion: @escaping (Result<Void, Error>) -> Void) {
        saveProfileCalled = true
        completion(.success(()))
    }

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func signOut(completion: @escaping (Error?) -> Void) {}
    func isUserLoggedIn() -> Bool { false }
    func isEmailVerified() -> Bool { false }
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {}
    func reloadUser(completion: @escaping (Error?) -> Void) {}
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {}
    func deleteUser(completion: @escaping (Error?) -> Void) {}
    func updateUser(uid: String, fields: [String : Any], completion: @escaping (Result<Void, any Error>) -> Void) {}
    func fetchTMDBGenresMerged(language: String, completion: @escaping (Result<[String], any Error>) -> Void) {}
    
}

class AuthenticationPresenterMock: AuthenticationPresenterProtocol {
    var viewController: (any FilmsReview.ViewControllerProtocol)?
    
    var didCreateProfileCalled = false
    var didFailError: Error?

    func didCreateProfile() {
        didCreateProfileCalled = true
    }

    func didFail(error: Error) {
        didFailError = error
    }

    func didRegister(user: User) {}
    func didLogin(user: User) {}
    func didResetPassword() {}
    func didConfirmEmail() {}
    
    func didStartLoadingGenres() {}
    func didLoadGenres(names: [String]) {}
    func didFailLoadingGenres(error: any Error) {}
    
    func didStartSavingFavoriteGenres() {}
    func didSaveFavoriteGenres() {}
    func didFailSavingFavoriteGenres(error: any Error) {}
}


final class AuthInteractorTests: XCTestCase {
    
    func testCreateProfileSuccess() {
        let worker = AuthenticationWorkerMock()
        let presenter = AuthenticationPresenterMock()
        let interactor = AuthenticationInteractor(presenter: presenter, worker: worker)
        
        interactor.createProfile(
            name: "Test User",
            birthday: Date(),
            avatarData: "fake-data".data(using: .utf8)
        )
        
        XCTAssertTrue(worker.uploadAvatarCalled)
        XCTAssertTrue(worker.saveProfileCalled)
        XCTAssertTrue(presenter.didCreateProfileCalled)
    }
    
    func testCreateProfileFailsWithoutUID() {
        let worker = AuthenticationWorkerMock()
        worker.getCurrentUserIDStub = nil
        let presenter = AuthenticationPresenterMock()
        let interactor = AuthenticationInteractor(presenter: presenter, worker: worker)

        interactor.createProfile(name: "Test", birthday: Date(), avatarData: nil)

        XCTAssertNotNil(presenter.didFailError)
        XCTAssertEqual((presenter.didFailError as NSError?)?.code, -1)
    }

    func testCreateProfileFailsWithoutEmail() {
        let worker = AuthenticationWorkerMock()
        worker.getCurrentUserEmailStub = nil
        let presenter = AuthenticationPresenterMock()
        let interactor = AuthenticationInteractor(presenter: presenter, worker: worker)

        interactor.createProfile(name: "Test", birthday: Date(), avatarData: nil)

        XCTAssertNotNil(presenter.didFailError)
        XCTAssertEqual((presenter.didFailError as NSError?)?.code, -2)
    }
}
