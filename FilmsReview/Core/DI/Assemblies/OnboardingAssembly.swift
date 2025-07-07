//
//  OnboardingAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import Swinject
import UIKit

class OnboardingAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(OnboardingViewController.self) { _ in
            OnboardingViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, vc in
            vc.interactor = resolver.resolve(OnboardingInteractor.self)!
            vc.router = resolver.resolve(OnboardingRouter.self)!
        }
        
        container.register(OnboardingWorker.self) { _ in
            OnboardingWorker()
        }.inObjectScope(.container)
        
        container.register(OnboardingInteractor.self) { resolver in
            OnboardingInteractor(
                presenter: resolver.resolve(OnboardingPresenter.self)!,
                worker: resolver.resolve(OnboardingWorker.self)!)
        }.inObjectScope(.graph)
        
        container.register(OnboardingPresenter.self) { _ in
            OnboardingPresenter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, presenter in
            presenter.viewController = resolver.resolve(OnboardingViewController.self)
        }
        
        container.register(OnboardingRouter.self) { _ in
            OnboardingRouter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, router in
            router.viewController = resolver.resolve(OnboardingViewController.self)
        }
        
    }
}
