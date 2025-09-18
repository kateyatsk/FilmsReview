//
//  
//  ProfileWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol ProfileWorkerProtocol {
    func fetchMovies()
}

final class ProfileWorker: ProfileWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
