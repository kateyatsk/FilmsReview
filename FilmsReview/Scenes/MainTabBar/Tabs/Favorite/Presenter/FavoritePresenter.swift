//
//  
//  FavoritePresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol FavoritePresenterProtocol: PresenterProtocol {
    func prepareMoviesToBeDisplayed()
}

final class FavoritePresenter: FavoritePresenterProtocol {
    weak var viewController: ViewControllerProtocol?

    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }

    func prepareMoviesToBeDisplayed() {
        print("Prepare movies to be displayed")

        if let movieListVC = viewController as? FavoriteViewController {
            movieListVC.updateMoviesTable()
        }
    }
}
