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
}

final class AuthenticationInteractor: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: AuthenticationWorker
    
    init(presenter: AuthenticationPresenter? = nil, worker: AuthenticationWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func register(email: String, password: String) {
        worker.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    (self?.presenter as? AuthenticationPresenterProtocol)?.didRegister(user: user)
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
}
