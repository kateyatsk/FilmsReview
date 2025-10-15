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
        container.register(SearchWorkerProtocol.self) { r in
            let tmdb   = r.resolve(TMDBServiceProtocol.self)!
            let images = r.resolve(ImageLoaderProtocol.self)!
            return SearchWorker(tmdb: tmdb, images: images)
        }
        .inObjectScope(.container)

        container.register(SearchPresenter.self) { _ in
            SearchPresenter()
        }
        .inObjectScope(.graph)
 
        container.register(SearchInteractor.self) { r in
            let worker = r.resolve(SearchWorkerProtocol.self)!
            return SearchInteractor(worker: worker)
        }
        .inObjectScope(.graph)

        container.register(SearchRouter.self) { _ in
            SearchRouter()
        }
        .inObjectScope(.graph)

        container.register(SearchViewController.self) { r in
            let vc = SearchViewController()
            let interactor = r.resolve(SearchInteractor.self)!
            let presenter = r.resolve(SearchPresenter.self)!
            let router = r.resolve(SearchRouter.self)!

            vc.interactor = interactor
            vc.router = router
            
            presenter.viewController = vc
            interactor.presenter = presenter
            router.viewController = vc
            
            return vc
        }
        .inObjectScope(.graph)
    }
}

