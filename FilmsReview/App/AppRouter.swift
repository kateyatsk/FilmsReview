//
//  AppRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

final class AppRouter {
    static func startApp(window: UIWindow) {
        if !AppSettings.isOnboardingShown {
            let onboardingVC = DependencyContainer.shared.container.resolve(OnboardingViewController.self)!
            window.rootViewController = onboardingVC
        } else {
            let movieListVC = DependencyContainer.shared.container.resolve(MovieListViewController.self)!
            window.rootViewController = UINavigationController(rootViewController: movieListVC)
        }
        window.makeKeyAndVisible()
    }
}
