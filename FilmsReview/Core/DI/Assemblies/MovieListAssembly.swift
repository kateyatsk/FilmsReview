//
//  MovieListAssembly.swift
//  FilmsReview
//
//  Created by Alex Mialeshka on 25/06/2025.
//

import Swinject

// Assembly for Scene
class MovieListAssembly: Assembly {
    func assemble(container: Container) {
        // Register ViewController
        container.register(MovieListViewController.self) { resolver in
            let initialView = MovieListViewController()
            
            return initialView
        }
        .inObjectScope(.container)
        .initCompleted { resolver, viewController in
            // Inject dependencies after initialization
            viewController.interactor = resolver.resolve(MovieListInteractor.self)!
            viewController.router = resolver.resolve(MovieListRouter.self)!
        }
        
        // Register Worker
        container.register(MovieListWorker.self) { resolver in
            MovieListWorker()
        }.inObjectScope(.container) // Singleton scope
        
        // Register Interactor
        container.register(MovieListInteractor.self) { resolver in
            MovieListInteractor(
                presenter: resolver.resolve(MovieListPresenter.self)!,
                worker: resolver.resolve(MovieListWorker.self)!)
        }.inObjectScope(.container)

        // Register Presenter
        container.register(MovieListPresenter.self) { resolver in
            MovieListPresenter(viewController: resolver.resolve(MovieListViewController.self)!)
        }.inObjectScope(.container)

        // Register Router
        container.register(MovieListRouter.self) { resolver in
            MovieListRouter(viewController: resolver.resolve(MovieListViewController.self)!)
        }.inObjectScope(.container)
    }
}
