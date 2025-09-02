//
//  AuthenticationInteractorTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 5.08.25.
//


import XCTest
@testable import FilmsReview

final class StubAuthWorker: AuthenticationWorkerProtocol {
    var didCallReset = false
    var didCallSaveProfile = false
    var didCallSignOut = false
    var didCallDeleteUser = false
    var didCallSendVerification = false
    var didCallReloadUser = false

    var saveProfileResult: Result<Void, Error> = .success(())
    var deleteUserError: Error? = nil
    var sendVerificationError: Error? = nil
    var reloadUserError: Error? = nil
    var emailVerified = false

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {}
    func getCurrentUserEmail() -> String? {""}
    func getCurrentUserID() -> String? {""}
    func uploadAvatar(data: Data?, userId: String, completion: @escaping (Result<URL?, any Error>) -> Void) {   completion(.success(nil))
    }
    func saveUserProfileToFirestore(uid: String, email: String, name: String, birthday: Date, avatarURL: URL?, completion: @escaping (Result<Void, any Error>) -> Void) {}
    
    func signOut(completion: @escaping (Error?) -> Void) {
        didCallSignOut = true
        completion(nil)
    }

    func isUserLoggedIn() -> Bool { false }
    func isEmailVerified() -> Bool { emailVerified }
    
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {
        didCallSendVerification = true
        completion(sendVerificationError)
    }
    
    func reloadUser(completion: @escaping (Error?) -> Void) {
        didCallReloadUser = true
        completion(reloadUserError)
    }
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        didCallReset = true
        completion(nil)
    }
    
    func saveUserProfile(name: String, birthday: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        didCallSaveProfile = true
        completion(saveProfileResult)
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        didCallDeleteUser = true
        completion(deleteUserError)
    }
    
    func updateUser(uid: String, fields: [String : Any], completion: @escaping (Result<Void, any Error>) -> Void) {}
    func fetchTMDBGenresMerged(language: String, completion: @escaping (Result<[String], any Error>) -> Void) {}
}


final class SpyAuthPresenter: AuthenticationPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    private(set) var didFailCalled = false
    private(set) var didResetPasswordCalled = false
    private(set) var didCreateProfileCalled = false
    private(set) var didResetEmailVerificationCalled = false
    private(set) var didConfirmEmailCalled = false

    func didRegister(user: User) {}
    func didLogin(user: User) {}
    func didFail(error: Error) { didFailCalled = true }
    func didConfirmEmail() { didConfirmEmailCalled = true }
    func didResetPassword() { didResetPasswordCalled = true }
    func didCreateProfile() { didCreateProfileCalled = true }
    
    func didStartLoadingGenres() {}
    func didLoadGenres(names: [String]) {}
    func didFailLoadingGenres(error: any Error) {}
    
    func didStartSavingFavoriteGenres() {}
    func didSaveFavoriteGenres() {}
    func didFailSavingFavoriteGenres(error: any Error) {}
    
}

final class AuthenticationInteractorTests: XCTestCase {
    var interactor: AuthenticationInteractor!
    var worker: StubAuthWorker!
    var presenter: SpyAuthPresenter!

    override func setUp() {
        super.setUp()
        worker = StubAuthWorker()
        interactor = AuthenticationInteractor(worker: worker)
        presenter = SpyAuthPresenter()
        interactor.presenter = presenter

    }

    override func tearDown() {
        interactor = nil
        worker = nil
        presenter = nil
        super.tearDown()
    }

    func testResetPasswordCallsWorkerAndNotifiesPresenter() {
        interactor.resetPassword(email: "a@b.c")
        XCTAssertTrue(worker.didCallReset, "Interactor должен вызвать worker.resetPassword()")

        let exp = expectation(description: "ожидаем didResetPassword")
        DispatchQueue.main.async {
            if self.presenter.didResetPasswordCalled { exp.fulfill() }
        }
        wait(for: [exp], timeout: 0.5)
    }


    func testSignOutResetsAuthorizedAndCallsWorker() {
        AppSettings.isAuthorized = true
        let exp = expectation(description: "ожидаем signOut completion")
        interactor.signOut { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertTrue(worker.didCallSignOut, "Interactor должен вызвать worker.signOut()")
        XCTAssertFalse(AppSettings.isAuthorized, "После signOut флаг isAuthorized должен сброситься")
    }

    func testDeleteAccountOnErrorDoesNotSignOut() {
        worker.deleteUserError = NSError(domain: "Del", code: 2)
        let exp = expectation(description: "ожидаем deleteAccount completion")
        interactor.deleteAccount { err in
            XCTAssertNotNil(err)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertTrue(worker.didCallDeleteUser, "Interactor должен вызвать worker.deleteUser()")
        XCTAssertFalse(worker.didCallSignOut, "При ошибке deleteUser не должно быть повторного signOut")
    }

    func testDeleteAccountOnSuccessSignsOut() {
        worker.deleteUserError = nil
        let exp = expectation(description: "ожидаем deleteAccount completion")
        interactor.deleteAccount { err in
            XCTAssertNil(err)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertTrue(worker.didCallDeleteUser, "Interactor должен вызвать worker.deleteUser()")
        XCTAssertTrue(worker.didCallSignOut, "После успешного deleteUser interactor должен вызвать signOut()")
        XCTAssertFalse(AppSettings.isAuthorized, "После удаления аккаунта флаг isAuthorized должен сброситься")
    }

    func testResendVerificationEmailSuccessCallsCallback() {
        worker.sendVerificationError = nil
        let exp = expectation(description: "ожидаем resendVerificationEmail success")
        interactor.resendVerificationEmail { result in
            switch result {
            case .success(): break
            case .failure: XCTFail("Не ожидали ошибку")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        XCTAssertTrue(worker.didCallSendVerification,
                      "Interactor должен вызвать worker.sendVerificationEmail()")
    }

    func testResendVerificationEmailFailureCallsCallbackWithError() {
        worker.sendVerificationError = NSError(domain: "Mail", code: 3)
        let exp = expectation(description: "ожидаем resendVerificationEmail failure")
        interactor.resendVerificationEmail { result in
            switch result {
            case .success: XCTFail("Не ожидали успех")
            case .failure: break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testCheckEmailVerifiedSuccessTrue() {
        worker.reloadUserError = nil
        worker.emailVerified = true
        let exp = expectation(description: "ожидаем checkEmailVerified success true")
        interactor.checkEmailVerified { result in
            switch result {
            case .success(let verified):
                XCTAssertTrue(verified)
            case .failure: XCTFail("Не ожидали ошибку")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
        XCTAssertTrue(worker.didCallReloadUser,
                      "Interactor должен вызвать worker.reloadUser()")
    }

    func testCheckEmailVerifiedSuccessFalse() {
        worker.reloadUserError = nil
        worker.emailVerified = false
        let exp = expectation(description: "ожидаем checkEmailVerified success false")
        interactor.checkEmailVerified { result in
            switch result {
            case .success(let verified):
                XCTAssertFalse(verified)
            case .failure: XCTFail("Не ожидали ошибку")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testCheckEmailVerifiedFailure() {
        worker.reloadUserError = NSError(domain: "Reload", code: 4)
        let exp = expectation(description: "ожидаем checkEmailVerified failure")
        interactor.checkEmailVerified { result in
            switch result {
            case .success: XCTFail("Не ожидали успех")
            case .failure: break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

}
