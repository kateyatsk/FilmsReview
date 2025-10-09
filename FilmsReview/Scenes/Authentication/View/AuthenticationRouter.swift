//
//
//  AuthenticationRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import Foundation
import Swinject
import UIKit

protocol AuthenticationRouterProtocol: RouterProtocol {
    func navigateToLogin()
    func navigateToSignUp()
    
    func routeToEmailVerification()
    func navigateToForgotPassword()
    func navigateToCheckYourEmail(email: String)
    func navigateToCreateProfile()
    func navigateToChooseInterests()
}

final class AuthenticationRouter: AuthenticationRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func navigateToSignUp() {
        guard let signUpVC = DependencyContainer.shared.container.resolve(SignUpViewController.self),
              let navController = viewController?.navigationController else {
            print("navigation setup failed")
            return
        }
        
        if let authVC = navController.viewControllers.first {
            navController.setViewControllers([authVC, signUpVC], animated: true)
        } else {
            print("AuthenticationViewController not found in navigation stack")
        }
    }
    
    func navigateToLogin() {
        guard let loginVC = DependencyContainer.shared.container.resolve(LoginViewController.self),
              let navController = viewController?.navigationController else {
            print("navigation setup failed")
            return
        }
        
        if let authVC = navController.viewControllers.first {
            navController.setViewControllers([authVC, loginVC], animated: true)
        } else {
            print("AuthenticationViewController not found in navigation stack")
        }
    }
    
    func routeToEmailVerification() {
        guard
            let verificationVC = DependencyContainer
                .shared
                .container
                .resolve(EmailVerificationViewController.self),
            let sourceVC = viewController
        else {
            fatalError("EmailVerificationViewController or source VC not found")
        }
        
        if let nav = sourceVC.navigationController {
            nav.pushViewController(verificationVC, animated: true)
        } else {
            verificationVC.modalPresentationStyle = .fullScreen
            sourceVC.present(verificationVC, animated: true)
        }
    }
    
    func navigateToForgotPassword() {
        guard let forgotVC = DependencyContainer.shared.container.resolve(ForgotPasswordViewController.self) else { return }
        viewController?.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    func navigateToCheckYourEmail(email: String) {
        guard let vc = DependencyContainer.shared.container.resolve(CheckEmailViewController.self) else { return }
        vc.email = email
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToCreateProfile() {
        guard let vc = DependencyContainer.shared.container.resolve(CreateProfileViewController.self) else { return }
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToChooseInterests() {
        guard
            let vc = DependencyContainer.shared.container.resolve(ChooseInterestsViewController.self),
            let source = viewController
        else { return }
        
        if let nav = source.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            source.present(vc, animated: true)
        }
    }
    
}
