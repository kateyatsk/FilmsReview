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
        AppRouter.updateRootViewController()
    }
}

