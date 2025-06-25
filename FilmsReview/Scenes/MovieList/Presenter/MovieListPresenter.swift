//
//  MovieListPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

protocol MovieListPresenterProtocol: PresenterProtocol {
    func prepareMoviesToBeDisplayed()
}

final class MovieListPresenter: MovieListPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func prepareMoviesToBeDisplayed() {
        print("Prepare movies to be displayed")
        
        if let movieListVC = viewController as? MovieListViewController {
            movieListVC.updateMoviesTable()
        }
    }
}
