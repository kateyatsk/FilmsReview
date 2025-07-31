//
//
//  AuthenticationInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import Foundation

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
}

final class AuthenticationInteractor: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: AuthenticationWorkerProtocol
    
    private var timer: Timer?
    
    init(presenter: AuthenticationPresenter? = nil, worker: AuthenticationWorkerProtocol) {
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
            timeInterval: 3,
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
    
}
