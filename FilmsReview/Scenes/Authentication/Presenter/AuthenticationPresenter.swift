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
    func didConfirmEmail()
}

final class AuthenticationPresenter: AuthenticationPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    func didRegister(user: User) {
        if user.isEmailVerified {
            AppSettings.isAuthorized = true
            AppRouter.updateRootViewController()
        } else {
            (viewController as? SignUpVCProtocol)?.showEmailVerificationScreen()
        }
    }
    
    func didLogin(user: User) {
        if user.isEmailVerified {
            AppSettings.isAuthorized = true
            AppRouter.updateRootViewController()
        } else {
            (viewController as? LoginVCProtocol)?.showEmailVerificationScreen()
        }
        
    }
    
    func didFail(error: Error) {
        viewController?.showErrorAlert(error.localizedDescription)
    }
    
    func didConfirmEmail() {
        AppSettings.isAuthorized = true
        AppRouter.updateRootViewController()
    }
    
}
