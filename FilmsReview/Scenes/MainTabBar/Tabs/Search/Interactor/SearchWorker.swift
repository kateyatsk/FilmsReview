//
//  
//  SearchWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol SearchWorkerProtocol {
    func fetchMovies()
}

final class SearchWorker: SearchWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
