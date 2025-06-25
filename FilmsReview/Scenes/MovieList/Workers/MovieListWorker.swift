//
//  MovieListWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import Foundation

protocol MovieListWorkerProtocol {
    func fetchMovies()
}

final class MovieListWorker: MovieListWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
