//
//  OnboardingRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import Swinject
import UIKit

protocol OnboardingRouterProtocol: RouterProtocol {
    func routeToMainApp()
}

final class OnboardingRouter: OnboardingRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func routeToMainApp() {
        let movieListVC = DependencyContainer.shared.container.resolve(MovieListViewController.self)!
        let nav = UINavigationController(rootViewController: movieListVC)
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}

