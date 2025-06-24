//
//  AppRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

final class AppRouter {
    static func startApp(window: UIWindow) {
        let vc = MovieListViewController()
        let navigation = UINavigationController(rootViewController: vc)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
}
