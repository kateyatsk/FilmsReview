//
//
//  SearchAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Swinject

class SearchAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SearchViewController.self) { resolver in
            let vc = SearchViewController()
            
            guard
                let router = resolver.resolve(SearchRouter.self),
                let interactor = resolver.resolve(SearchInteractor.self),
                let presenter = resolver.resolve(SearchPresenter.self)
            else {
                fatalError("DI Error: SearchRouter/SearchInteractor/SearchPresenter не зарегистрирован")
            }
            
            presenter.viewController = vc
            vc.interactor = interactor
            vc.router = router
            router.viewController = vc
            
            return vc
        }
        .inObjectScope(.graph)
        
        container.register(SearchWorker.self) { _ in
            SearchWorker()
        }.inObjectScope(.container)
        
        container.register(SearchInteractor.self) { resolver in
            guard
                let presenter = resolver.resolve(SearchPresenter.self),
                let worker = resolver.resolve(SearchWorker.self)
            else {
                fatalError("DI Error: SearchPresenter или SearchWorker не зарегистрирован")
            }
            return SearchInteractor(presenter: presenter, worker: worker)
        }
        .inObjectScope(.graph)
        
        container.register(SearchPresenter.self) { _ in
            SearchPresenter()
        }
        .inObjectScope(.graph)
        .initCompleted { resolver, presenter in
            presenter.viewController = resolver.resolve(SearchViewController.self)
        }
        
        container.register(SearchRouter.self) { _ in
            SearchRouter()
        }
        .inObjectScope(.container)
        .initCompleted { resolver, router in
            router.viewController = resolver.resolve(SearchViewController.self)
        }
    }
}
