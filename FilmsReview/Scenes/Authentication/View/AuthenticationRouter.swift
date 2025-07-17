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
}
