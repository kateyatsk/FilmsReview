//
//
//  AuthenticationPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import UIKit

protocol AuthenticationPresenterProtocol: PresenterProtocol {
    func didRegister(user: User)
    func didLogin(user: User)
    func didFail(error: Error)
}

final class AuthenticationPresenter: AuthenticationPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    func didRegister(user: User) {
        AppRouter.updateRootViewController()
    }
    
    func didLogin(user: User) {
        AppRouter.updateRootViewController()
        
    }
    
    func didFail(error: Error) {
        viewController?.showErrorAlert(error.localizedDescription)
    }
    
}
