//
//  MovieListInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import Foundation

protocol MovieListInteractorProtocol: InteractorProtocol {
    func sendFetchRequestToAPI()
}

final class MovieListInteractor: MovieListInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: MovieListWorker
    
    
    init(presenter: MovieListPresenter? = nil, worker: MovieListWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func sendFetchRequestToAPI() {
        print("Have sent request to worker")
        worker.fetchMovies()
        
        if let presenter = presenter as? MovieListPresenter {
            presenter.prepareMoviesToBeDisplayed()
        }
    }
}
