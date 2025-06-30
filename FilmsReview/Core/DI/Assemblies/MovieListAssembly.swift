//
//  MovieListAssembly.swift
//  FilmsReview
//
//  Created by Alex Mialeshka on 25/06/2025.
//

import Swinject

class MovieListAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MovieListViewController.self) { _ in
           MovieListViewController()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, viewController in
            viewController.interactor = resolver.resolve(MovieListInteractor.self)!
            viewController.router = resolver.resolve(MovieListRouter.self)!
        }
        
        container.register(MovieListWorker.self) { _ in
            MovieListWorker()
        }.inObjectScope(.container)
        
        container.register(MovieListInteractor.self) { resolver in
            MovieListInteractor(
                presenter: resolver.resolve(MovieListPresenter.self)!,
                worker: resolver.resolve(MovieListWorker.self)!)
        }.inObjectScope(.graph)
        
        container.register(MovieListPresenter.self) { _ in
            MovieListPresenter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, presenter in
            presenter.viewController = resolver.resolve(MovieListViewController.self)
        }
        
        container.register(MovieListRouter.self) { _ in
            MovieListRouter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, router in
            router.viewController = resolver.resolve(MovieListViewController.self)
        }
    }
}
