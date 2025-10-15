//
//
//  AuthenticationInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import Foundation

fileprivate enum AuthConst {
    enum Timing {
        static let emailPollInterval: TimeInterval = 3.0
    }
    enum Domain {
        static let createProfile = "CreateProfile"
        static let saveGenres    = "SaveGenres"
    }
    
    enum Field {
        static let favoriteGenres = "favoriteGenres"
    }
    
    enum Message {
        static let userNotLoggedIn = "User not logged in"
        static let emailNotFound   = "Email not found"
    }
}

fileprivate enum CreateProfileError: Int, LocalizedError, CustomNSError {
    case userNotLoggedIn = -1
    case emailNotFound   = -2
    
    static var errorDomain: String {  AuthConst.Domain.createProfile  }
    var errorCode: Int { rawValue }
    var errorUserInfo: [String : Any] { [NSLocalizedDescriptionKey: errorDescription ?? ""] }
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn: return AuthConst.Message.userNotLoggedIn
        case .emailNotFound:   return  AuthConst.Message.emailNotFound
        }
    }
}

protocol AuthenticationInteractorProtocol: InteractorProtocol {
    func register(email: String, password: String)
    func login(email: String, password: String)
    func signOut(completion: @escaping (Error?) -> Void)
    
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void)
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void)
    func startEmailVerificationMonitoring()
    func stopEmailVerificationMonitoring()
    
    func deleteAccount(completion: @escaping (Error?) -> Void)
    
    func validateEmail(_ email: String) -> Bool
    func resetPassword(email: String)
    func createProfile(
        name: String,
        birthday: Date,
        avatarData: Data?
    )
    func saveFavoriteGenres(_ genres: [String])
    
    func fetchTMDBGenres(language: String)
}

final class AuthenticationInteractor: AuthenticationInteractorProtocol {
    
    var presenter: (any PresenterProtocol)?
    var worker: AuthenticationWorkerProtocol
    
    private var timer: Timer?
    
    init(presenter: AuthenticationPresenterProtocol? = nil, worker: AuthenticationWorkerProtocol) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func register(email: String, password: String) {
        worker.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    user.sendEmailVerification() { error in
                        if let error = error {
                            (self?.presenter as? AuthenticationPresenterProtocol)?.didFail(error: error)
                        } else {
                            (self?.presenter as? AuthenticationPresenterProtocol)?.didRegister(user: user)
                        }
                    }
                case .failure(let error):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didFail(error: error)
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        worker.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didLogin(user: user)
                case .failure(let error):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didFail(error: error)
                }
            }
        }
    }
    
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {
        worker.sendVerificationEmail { error in
            if let err = error { completion(.failure(err))} else { completion(.success(())) }
        }
    }
    
    func startEmailVerificationMonitoring() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(
            timeInterval: AuthConst.Timing.emailPollInterval,
            target: self,
            selector: #selector(pollEmailVerificationStatus),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopEmailVerificationMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void) {
        worker.reloadUser { error in
            if let err = error {
                completion(.failure(err))
            } else {
                let verified = self.worker.isEmailVerified()
                completion(.success(verified))
            }
        }
    }
    
    @objc private func pollEmailVerificationStatus() {
        checkEmailVerified { [weak self] result in
            switch result {
            case .success(true):
                self?.stopEmailVerificationMonitoring()
                (self?.presenter as? AuthenticationPresenterProtocol)?.didConfirmEmail()
            case .success(false):
                break
            case .failure(let error):
                (self?.presenter as? AuthenticationPresenterProtocol)?.didFail(error: error)
            }
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        AppSettings.isAuthorized = false
        worker.signOut(completion: completion)
    }
    
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        worker.deleteUser { [weak self] error in
            if let error = error {
                completion(error)
            } else {
                AppSettings.isAuthorized = false
                self?.worker.signOut(completion: completion)
            }
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", ValidationRegex.email.rawValue)
            .evaluate(with: email)
    }
    
    func resetPassword(email: String) {
        worker.resetPassword(email: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didFail(error: error)
                } else {
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didResetPassword()
                }
            }
        }
    }
    
    func createProfile(
        name: String,
        birthday: Date,
        avatarData: Data?
    ) {
        guard let uid = worker.getCurrentUserID() else {
            (presenter as? AuthenticationPresenterProtocol)?.didFail(error: CreateProfileError.userNotLoggedIn)
            return
        }
        
        guard let email = worker.getCurrentUserEmail() else {
            (presenter as? AuthenticationPresenterProtocol)?.didFail(error: CreateProfileError.emailNotFound)
            return
        }
        
        worker.uploadAvatar(data: avatarData, userId: uid) { [weak self] result in
            switch result {
            case .success(let avatarURL):
                self?.worker.saveUserProfileToFirestore(
                    uid: uid,
                    email: email,
                    name: name,
                    birthday: birthday,
                    avatarURL: avatarURL
                ) { result in
                    switch result {
                    case .success:
                        AppSettings.isAuthorized = true
                        (self?.presenter as? AuthenticationPresenterProtocol)?
                            .didCreateProfile()
                    case .failure(let error):
                        (self?.presenter as? AuthenticationPresenterProtocol)?
                            .didFail(error: error)
                    }
                }
                
            case .failure(let error):
                (self?.presenter as? AuthenticationPresenterProtocol)?
                    .didFail(error: error)
            }
        }
    }
    
    func saveFavoriteGenres(_ genres: [String]) {
        (presenter as? AuthenticationPresenterProtocol)?.didStartSavingFavoriteGenres()
        
        guard let uid = worker.getCurrentUserID() else {
            (presenter as? AuthenticationPresenterProtocol)?
                .didFailSavingFavoriteGenres(error: NSError(domain:  AuthConst.Domain.saveGenres, code: -1,
                                                            userInfo: [NSLocalizedDescriptionKey: AuthConst.Message.userNotLoggedIn]))
            return
        }
        
        worker.updateUser(uid: uid, fields: [AuthConst.Field.favoriteGenres: genres]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didSaveFavoriteGenres()
                case .failure(let error):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didFailSavingFavoriteGenres(error: error)
                }
            }
        }
    }
    
    func fetchTMDBGenres(language: String) {
        (presenter as? AuthenticationPresenterProtocol)?.didStartLoadingGenres()
        worker.fetchTMDBGenresMerged(language: language) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let names):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didLoadGenres(names: names)
                case .failure(let error):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didFailLoadingGenres(error: error)
                }
            }
        }
    }
}
