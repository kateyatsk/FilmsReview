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
            let onboardingVC = DependencyContainer.shared.container.resolve(OnboardingFirstViewController.self)!
            let interactor = DependencyContainer.shared.container.resolve(OnboardingInteractor.self)!
            let presenter = DependencyContainer.shared.container.resolve(OnboardingPresenter.self)!
            let router = DependencyContainer.shared.container.resolve(OnboardingRouter.self)!
            
            onboardingVC.interactor = interactor
            onboardingVC.router = router
            
            presenter.viewController = onboardingVC
            router.viewController = onboardingVC
            window.rootViewController = UINavigationController(rootViewController: onboardingVC)
        } else {
            let movieListVC = DependencyContainer.shared.container.resolve(MovieListViewController.self)!
            window.rootViewController = UINavigationController(rootViewController: movieListVC)

        }
        window.makeKeyAndVisible()
    }
}
