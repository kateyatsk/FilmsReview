//
//  
//  ProfileInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol ProfileInteractorProtocol: InteractorProtocol {
    func sendFetchRequestToAPI()
}

final class ProfileInteractor: ProfileInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: ProfileWorker

    init(presenter: ProfilePresenter? = nil, worker: ProfileWorker) {
        self.presenter = presenter
        self.worker = worker
    }

    func sendFetchRequestToAPI() {
        print("Have sent request to worker")
        worker.fetchMovies()

        if let presenter = presenter as? ProfilePresenter {
            presenter.prepareMoviesToBeDisplayed()
        }
    }
}
