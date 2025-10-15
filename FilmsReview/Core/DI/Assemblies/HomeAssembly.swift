//
//
//  HomeAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Swinject

class HomeAssembly: Assembly {
    func assemble(container: Container) {
        container.register(HomeViewController.self) { resolver in
            let vc = HomeViewController()
            
            guard
                let router = resolver.resolve(HomeRouter.self),
                let interactor = resolver.resolve(HomeInteractor.self),
                let presenter = resolver.resolve(HomePresenter.self)
            else {
                fatalError("DI Error: HomeRouter, HomeInteractor или HomePresenter не зарегистрирован")
            }
            
            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor
            vc.router = router
            router.viewController = vc
            
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(HomeWorker.self) { resolver in
            guard
                let tmdb = resolver.resolve(TMDBServiceProtocol.self),
                let images = resolver.resolve(ImageLoaderProtocol.self)
            else {
                fatalError("TMDBServiceProtocol/ImageLoaderProtocol not registered")
            }
            return HomeWorker(tmdbService: tmdb, images: images)
        }
        .inObjectScope(.container)
        
        
        container.register(HomeInteractor.self) { resolver in
            guard
                let worker = resolver.resolve(HomeWorker.self)
            else {
                fatalError("DI Error: HomeWorker не зарегистрирован")
            }
            return HomeInteractor(worker: worker)
        }
        .inObjectScope(.container)
        
        container.register(HomePresenter.self) { _ in
            HomePresenter()
        }
        .inObjectScope(.graph)
        
        container.register(HomeRouter.self) { _ in
            HomeRouter()
        }
        .inObjectScope(.container)
        
        container.register(MediaListViewController.self) { resolver in
            let vc = MediaListViewController()
            
            guard
                let mainRouter = resolver.resolve(HomeRouter.self),
                let homeInteractor = resolver.resolve(HomeInteractor.self),
                let presenter = resolver.resolve(HomePresenter.self)
            else {
                fatalError("DI Error: HomeRouter, HomeInteractor или HomePresenter не зарегистрирован для MediaListViewController")
            }
            
            vc.router = mainRouter
            vc.interactor = homeInteractor
            
            mainRouter.viewController = vc
            presenter.viewController = vc
            homeInteractor.presenter = presenter
            
            return vc
        }
        .inObjectScope(.transient)
        
    }
}
