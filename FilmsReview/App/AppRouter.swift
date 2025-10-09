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
        
        if !AppSettings.isOnboardingShown {
            guard let onboardingVC = container.resolve(OnboardingViewController.self) else {
                fatalError("DI Error: OnboardingViewController not registered")
            }
            window.rootViewController = onboardingVC
            return
        }

        if !AppSettings.isAuthorized {
            guard let authVC = container.resolve(AuthenticationViewController.self) else {
                fatalError("DI Error: AuthViewController not resolved")
            }
            window.rootViewController = UINavigationController(rootViewController: authVC)
            return
        }
        
        guard let tabBar = container.resolve(TabBarViewController.self) else {
            fatalError("DI Error: TabBarViewController not resolved")
        }
        window.rootViewController = tabBar
    }
    
}
