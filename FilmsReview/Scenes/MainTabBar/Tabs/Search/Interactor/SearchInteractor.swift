//
//  
//  SearchInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol SearchInteractorProtocol: InteractorProtocol {
    func sendFetchRequestToAPI()
}

final class SearchInteractor: SearchInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: SearchWorker

    init(presenter: SearchPresenter? = nil, worker: SearchWorker) {
        self.presenter = presenter
        self.worker = worker
    }

    func sendFetchRequestToAPI() {
        print("Have sent request to worker")
        worker.fetchMovies()

        if let presenter = presenter as? SearchPresenter {
            presenter.prepareMoviesToBeDisplayed()
        }
    }
}
