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
    func didResetPassword()
    func didCreateProfile()
}

final class AuthenticationPresenter: AuthenticationPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    func didRegister(user: User) {
        (viewController as? SignUpViewController)?.finishSubmitting()
        if user.isEmailVerified {
            AppSettings.isAuthorized = true
            AppRouter.updateRootViewController()
        } else {
            (viewController as? SignUpVCProtocol)?.showEmailVerificationScreen()
        }
    }
    
    func didLogin(user: User) {
        (viewController as? LoginViewController)?.finishSubmitting()
        if user.isEmailVerified {
            AppSettings.isAuthorized = true
            AppRouter.updateRootViewController()
        } else {
            (viewController as? LoginVCProtocol)?.showEmailVerificationScreen()
        }
        
    }
    
    func didFail(error: Error) {
        (viewController as? SignUpViewController)?.finishSubmitting()
        (viewController as? LoginViewController)?.finishSubmitting()
        viewController?.showErrorAlert(error.localizedDescription)
    }
    
    func didConfirmEmail() {
        (viewController?.router as? AuthenticationRouterProtocol)?.navigateToCreateProfile()
    }
    
    func didResetPassword() {
        (viewController as? ForgotPasswordVCProtocol)?.showCheckYourEmailScreen()
    }
    
    func didCreateProfile() {
        AppSettings.isAuthorized = true
        AppRouter.updateRootViewController()
    }
}
