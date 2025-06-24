//
//  MovieListRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import Foundation

protocol MovieListRoutingLogic {}

protocol MovieListDataPassing {
    var dataStore: MovieListDataStore? { get }
}

final class MovieListRouter: MovieListRoutingLogic, MovieListDataPassing {
    weak var viewController: MovieListViewController?
    var dataStore: MovieListDataStore?
}
