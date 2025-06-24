//
//  MovieListInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import Foundation

protocol MovieListBusinessLogic {}

protocol MovieListDataStore {}

final class MovieListInteractor: MovieListBusinessLogic, MovieListDataStore {
    var presenter: MovieListPresentationLogic?
    var worker = MovieListWorker()
    
}
