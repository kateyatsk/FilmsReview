//
//
//  MainTabBarInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import Foundation

protocol MainTabBarInteractorProtocol: InteractorProtocol {
//    func load(request: Home.Load.Request)
}

final class MainTabBarInteractor: MainTabBarInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: MainTabBarWorker
    
    init(presenter: MainTabBarPresenter? = nil, worker: MainTabBarWorker) {
        self.presenter = presenter
        self.worker = worker
    }
//    
//    func load(request: Home.Load.Request) {
//        presenter?.presentLoading()
//        worker.fetchHome(language: request.language) { [weak self] result in
//            switch result {
//            case .success(let response):
//                self?.presenter?.presentLoaded(response)
//            case .failure(let error):
//                self?.presenter?.presentError(error)
//            }
//        }
//    }
}
