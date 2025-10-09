//
//
//  ProfileAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Swinject

class ProfileAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ProfileViewController.self) { resolver in
            let vc = ProfileViewController()
            
            guard
                let router = resolver.resolve(ProfileRouter.self),
                let interactor = resolver.resolve(ProfileInteractor.self),
                let presenter = resolver.resolve(ProfilePresenter.self)
            else {
                fatalError("DI Error: ProfileRouter/ProfileInteractor/ProfilePresenter не зарегистрирован")
            }
            
            presenter.viewController = vc
            vc.interactor = interactor
            vc.router = router
            router.viewController = vc
            
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(ProfileWorker.self) { _ in
            ProfileWorker()
        }
        .inObjectScope(.container)
        
        container.register(ProfileInteractor.self) { resolver in
            guard
                let presenter = resolver.resolve(ProfilePresenter.self),
                let worker = resolver.resolve(ProfileWorker.self)
            else {
                fatalError("DI Error: ProfilePresenter или ProfileWorker не зарегистрирован")
            }
            return ProfileInteractor(presenter: presenter, worker: worker)
        }
        .inObjectScope(.graph)
        
        container.register(ProfilePresenter.self) { _ in
            ProfilePresenter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, presenter in
            presenter.viewController = resolver.resolve(ProfileViewController.self)
        }
        
        container.register(ProfileRouter.self) { _ in
            ProfileRouter()
        }
        .inObjectScope(.container)
        .initCompleted { resolver, router in
            router.viewController = resolver.resolve(ProfileViewController.self)
        }
    }
}
