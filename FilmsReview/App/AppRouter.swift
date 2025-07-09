//
//  AppRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

final class AppRouter {
    static func startApp(window: UIWindow) {
        let container = DependencyContainer.shared.container
        
        if !AppSettings.isOnboardingShown {
            guard let onboardingVC = container.resolve(OnboardingViewController.self) else {
                fatalError("DI Error: OnboardingViewController not registered")
            }
            window.rootViewController = onboardingVC
        } else {
            guard let movieListVC = container.resolve(MovieListViewController.self) else {
                fatalError("DI Error: MovieListViewController not resolved")
            }
            window.rootViewController = UINavigationController(rootViewController: movieListVC)
        }
        window.makeKeyAndVisible()
    }
}
