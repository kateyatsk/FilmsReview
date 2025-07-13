//
//  
//  AuthenticationAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import Swinject

class AuthenticationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthenticationViewController.self) { _ in
           AuthenticationViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, viewController in
            viewController.interactor = resolver.resolve(AuthenticationInteractor.self)!
            viewController.router = resolver.resolve(AuthenticationRouter.self)!
        }
        
        container.register(AuthenticationWorker.self) { _ in
            AuthenticationWorker()
        }.inObjectScope(.container)
        
        container.register(AuthenticationInteractor.self) { resolver in
            AuthenticationInteractor(
                presenter: resolver.resolve(AuthenticationPresenter.self)!,
                worker: resolver.resolve(AuthenticationWorker.self)!)
        }.inObjectScope(.graph)
        
        container.register(AuthenticationPresenter.self) { _ in
            AuthenticationPresenter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, presenter in
            presenter.viewController = resolver.resolve(AuthenticationViewController.self)
        }
        
        container.register(AuthenticationRouter.self) { _ in
            AuthenticationRouter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, router in
            router.viewController = resolver.resolve(AuthenticationViewController.self)
        }
    }
}
