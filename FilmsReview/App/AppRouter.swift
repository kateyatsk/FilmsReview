//
//  AppRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

final class AppRouter {
    static func startApp(window: UIWindow) {
        let viewController = DependencyContainer.shared.container.resolve(MovieListViewController.self)!
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
    }
}
