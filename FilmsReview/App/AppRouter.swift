//
//  AppRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

final class AppRouter {
    static var window: UIWindow?
    
    static func startApp(window: UIWindow) {
        self.window = window
        updateRootViewController()
        window.makeKeyAndVisible()
    }
    
    static func updateRootViewController() {
        guard let window = window else { return }
        let container = DependencyContainer.shared.container
        let authManager = FirebaseAuthManager.shared
        
        if !AppSettings.isOnboardingShown {
            guard let onboardingVC = container.resolve(OnboardingViewController.self) else {
                fatalError("DI Error: OnboardingViewController not registered")
            }
            window.rootViewController = onboardingVC
            return
        }
        
        if authManager.isUserLoggedIn(), !authManager.isEmailVerified() {
            guard let verificationVC = container.resolve(EmailVerificationViewController.self) else {
                fatalError("DI Error: EmailVerificationViewController not resolved")
            }
            window.rootViewController = UINavigationController(rootViewController: verificationVC)
            return
        }
        
        if !authManager.isUserLoggedIn() {
            guard let authVC = container.resolve(AuthenticationViewController.self) else {
                fatalError("DI Error: AuthViewController not resolved")
            }
            window.rootViewController = UINavigationController(rootViewController: authVC)
            return
        }
        
        guard let movieListVC = container.resolve(MovieListViewController.self) else {
            fatalError("DI Error: MovieListViewController not resolved")
        }
        window.rootViewController = UINavigationController(rootViewController: movieListVC)
        
    }
    
}
