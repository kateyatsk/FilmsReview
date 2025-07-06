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
    
}

final class OnboardingRouter: OnboardingRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func routeToSecond() {
        guard let currentVC = viewController as? UIViewController else { return }
        
        let nextVC = DependencyContainer.shared.container.resolve(OnboardingSecondViewController.self)!
        nextVC.interactor = (currentVC as? OnboardingFirstViewController)?.interactor
        nextVC.router = self
        
        self.viewController = nextVC
        
        
        nextVC.navigationItem.hidesBackButton = true
        
        currentVC.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func routeToThird() {
          guard let currentVC = viewController as? UIViewController else { return }

          let nextVC = DependencyContainer.shared.container.resolve(OnboardingThirdViewController.self)!
          nextVC.interactor = (currentVC as? OnboardingSecondViewController)?.interactor
          nextVC.router = self

          self.viewController = nextVC

          nextVC.navigationItem.hidesBackButton = true

          currentVC.navigationController?.pushViewController(nextVC, animated: true)
      }
    
    
    func finishOnboarding() {
            guard let currentVC = viewController as? UIViewController else { return }

            AppSettings.isOnboardingShown = true

            let mainVC = DependencyContainer.shared.container.resolve(MovieListViewController.self)!
            let navController = UINavigationController(rootViewController: mainVC)
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle = .fullScreen

            currentVC.view.window?.rootViewController = navController
            currentVC.view.window?.makeKeyAndVisible()
        }
}
