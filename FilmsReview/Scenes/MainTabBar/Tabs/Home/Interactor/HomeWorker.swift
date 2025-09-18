//
//  
//  HomeWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol HomeWorkerProtocol {
    func fetchMovies()
}

final class HomeWorker: HomeWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
