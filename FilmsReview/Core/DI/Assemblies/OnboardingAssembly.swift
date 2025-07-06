//
//  OnboardingAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import Swinject

class OnboardingAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(OnboardingFirstViewController.self) { _ in
           OnboardingFirstViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, viewController in
            viewController.interactor = resolver.resolve(OnboardingInteractor.self)!
            viewController.router = resolver.resolve(OnboardingRouter.self)!
        }
        
        container.register(OnboardingSecondViewController.self) { _ in
           OnboardingSecondViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, viewController in
            viewController.interactor = resolver.resolve(OnboardingInteractor.self)!
            viewController.router = resolver.resolve(OnboardingRouter.self)!
        }
        
        container.register(OnboardingThirdViewController.self) { _ in
           OnboardingThirdViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, viewController in
            viewController.interactor = resolver.resolve(OnboardingInteractor.self)!
            viewController.router = resolver.resolve(OnboardingRouter.self)!
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
        
        container.register(OnboardingRouter.self) { _ in
            OnboardingRouter()
        }
        .inObjectScope(.graph)
        
    }
}
