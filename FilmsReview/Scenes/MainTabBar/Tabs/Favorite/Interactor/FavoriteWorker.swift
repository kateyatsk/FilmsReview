//
//  
//  FavoriteWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol FavoriteWorkerProtocol {
    func fetchMovies()
}

final class FavoriteWorker: FavoriteWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
