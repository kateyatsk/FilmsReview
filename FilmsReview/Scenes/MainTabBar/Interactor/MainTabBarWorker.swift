//
//  
//  MainTabBarWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import Foundation

protocol MainTabBarWorkerProtocol {
    func fetchMovies()
}

final class MainTabBarWorker: MainTabBarWorkerProtocol {
    func fetchMovies() {
        print("Fetching movies...")
    }
}
