//
//  
//  HomeInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol HomeInteractorProtocol: InteractorProtocol {
    func sendFetchRequestToAPI()
}

final class HomeInteractor: HomeInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: HomeWorker

    init(presenter: HomePresenter? = nil, worker: HomeWorker) {
        self.presenter = presenter
        self.worker = worker
    }

    func sendFetchRequestToAPI() {
        print("Have sent request to worker")
        worker.fetchMovies()

        if let presenter = presenter as? HomePresenter {
            presenter.prepareMoviesToBeDisplayed()
        }
    }
}
