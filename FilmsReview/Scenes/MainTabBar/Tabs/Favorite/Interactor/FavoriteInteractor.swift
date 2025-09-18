//
//  
//  FavoriteInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol FavoriteInteractorProtocol: InteractorProtocol {
    func sendFetchRequestToAPI()
}

final class FavoriteInteractor: FavoriteInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: FavoriteWorker

    init(presenter: FavoritePresenter? = nil, worker: FavoriteWorker) {
        self.presenter = presenter
        self.worker = worker
    }

    func sendFetchRequestToAPI() {
        print("Have sent request to worker")
        worker.fetchMovies()

        if let presenter = presenter as? FavoritePresenter {
            presenter.prepareMoviesToBeDisplayed()
        }
    }
}
