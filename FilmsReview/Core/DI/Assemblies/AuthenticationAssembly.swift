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
        
        container.register(AuthenticationRouter.self) { _ in AuthenticationRouter() }
            .inObjectScope(.container)
        
        container.register(AuthenticationWorker.self) { _ in AuthenticationWorker() }
            .inObjectScope(.container)
        
        container.register(AuthenticationPresenter.self) { _ in AuthenticationPresenter() }
            .inObjectScope(.graph)
        
        container.register(AuthenticationInteractor.self) { resolver in
            guard
                let presenter = resolver.resolve(AuthenticationPresenter.self),
                let worker = resolver.resolve(AuthenticationWorker.self)
            else {
                fatalError("DI Error: AuthenticationPresenter или AuthenticationWorker не зарегистрированы")
            }
            return AuthenticationInteractor(presenter: presenter, worker: worker)
        }
        .inObjectScope(.graph)
        
        container.register(AuthenticationViewController.self) { resolver in
            let vc = AuthenticationViewController()
            guard
                let router = resolver.resolve(AuthenticationRouter.self),
                let interactor = resolver.resolve(AuthenticationInteractor.self),
                let presenter = resolver.resolve(AuthenticationPresenter.self)
            else {
                fatalError("DI Error: AuthenticationRouter, AuthenticationInteractor или AuthenticationPresenter не зарегистрирован")
            }
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            router.viewController = vc
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(LoginViewController.self) { resolver in
            let vc = LoginViewController()
            guard
                let router = resolver.resolve(AuthenticationRouter.self),
                let interactor = resolver.resolve(AuthenticationInteractor.self),
                let presenter = resolver.resolve(AuthenticationPresenter.self)
            else {
                fatalError("DI Error: AuthenticationRouter, AuthenticationInteractor или AuthenticationPresenter не зарегистрирован")
            }
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(SignUpViewController.self) { resolver in
            let vc = SignUpViewController()
            guard
                let router = resolver.resolve(AuthenticationRouter.self),
                let interactor = resolver.resolve(AuthenticationInteractor.self),
                let presenter = resolver.resolve(AuthenticationPresenter.self)
            else {
                fatalError("DI Error: AuthenticationRouter, AuthenticationInteractor или AuthenticationPresenter не зарегистрирован")
            }
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(EmailVerificationViewController.self) { resolver in
            let vc = EmailVerificationViewController()
            guard
                let interactor = resolver.resolve(AuthenticationInteractor.self)
            else {
                fatalError("DI Error: AuthenticationInteractor не зарегистрирован")
            }
            vc.interactor = interactor
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(ForgotPasswordViewController.self) { resolver in
            let vc = ForgotPasswordViewController()
            guard
                let router = resolver.resolve(AuthenticationRouter.self),
                let interactor = resolver.resolve(AuthenticationInteractor.self),
                let presenter = resolver.resolve(AuthenticationPresenter.self)
            else {
                fatalError("DI Error: AuthenticationRouter, AuthenticationInteractor или AuthenticationPresenter не зарегистрирован")
            }
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(CheckEmailViewController.self) { resolver in
            let vc = CheckEmailViewController()
            guard
                let router = resolver.resolve(AuthenticationRouter.self),
                let interactor = resolver.resolve(AuthenticationInteractor.self),
                let presenter = resolver.resolve(AuthenticationPresenter.self)
            else {
                fatalError("DI Error: AuthenticationRouter, AuthenticationInteractor или AuthenticationPresenter не зарегистрирован")
            }
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            return vc
        }
        .inObjectScope(.graph)
        
    }
}
