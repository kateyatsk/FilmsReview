//
//
//  FavoriteAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Swinject

class FavoriteAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FavoriteViewController.self) { resolver in
            let vc = FavoriteViewController()

            guard
                let router = resolver.resolve(FavoriteRouter.self),
                let interactor = resolver.resolve(FavoriteInteractor.self),
                let presenter = resolver.resolve(FavoritePresenter.self)
            else {
                fatalError("DI Error: FavoriteRouter, FavoriteInteractor или FavoritePresenter не зарегистрирован")
            }

            presenter.viewController = vc
            vc.interactor = interactor
            vc.router = router
            router.viewController = vc

            return vc
        }
        .inObjectScope(.graph)

        container.register(FavoriteWorker.self) { resolver in
            guard let tmdb = resolver.resolve(TMDBServiceProtocol.self) else {
                fatalError("DI Error: TMDBServiceProtocol не зарегистрирован")
            }
            return FavoriteWorker(tmdb: tmdb)
        }
        .inObjectScope(.container)

        container.register(FavoriteInteractor.self) { resolver in
            guard
                let presenter = resolver.resolve(FavoritePresenter.self),
                let worker = resolver.resolve(FavoriteWorker.self)
            else {
                fatalError("DI Error: FavoritePresenter или FavoriteWorker не зарегистрирован")
            }
            return FavoriteInteractor(presenter: presenter, worker: worker)
        }
        .inObjectScope(.graph)

        container.register(FavoritePresenter.self) { _ in
            FavoritePresenter()
        }
        .inObjectScope(.graph)

        container.register(FavoriteRouter.self) { _ in
            FavoriteRouter()
        }
        .inObjectScope(.container)
    }
}
