//
//
//  MainTabBarPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import UIKit

protocol MainTabBarPresenterProtocol: PresenterProtocol {
    func presentCast(_ cast: [CastVM])
    func presentReviews(_ reviews: [ReviewVM])
    func presentSuggested(_ items: [MediaItem])
    func presentTVSeasons(titles: [String], selectedIndex: Int, episodes: [EpisodeVM])
    func presentTVSeasonEpisodes(episodes: [EpisodeVM], selectedIndex: Int)
    func presentError(_ error: Error)
}

final class MainTabBarPresenter: MainTabBarPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func presentCast(_ cast: [CastVM]) {
        (viewController as? MovieDetailsViewController)?.updateCast(cast)
    }
    
    func presentReviews(_ reviews: [ReviewVM]) {
        (viewController as? MovieDetailsViewController)?.updateReviews(reviews)
    }
    
    func presentSuggested(_ items: [MediaItem]) {
        (viewController as? MovieDetailsViewController)?.updateSuggested(items)
    }
    
    func presentTVSeasons(titles: [String], selectedIndex: Int, episodes: [EpisodeVM]) {
        (viewController as? MovieDetailsViewController)?
            .updateTVSeasons(titles: titles, selectedIndex: selectedIndex, episodes: episodes)
    }
    
    func presentTVSeasonEpisodes(episodes: [EpisodeVM], selectedIndex: Int) {
        (viewController as? MovieDetailsViewController)?
            .updateTVSeasonEpisodes(episodes: episodes, selectedIndex: selectedIndex)
    }
    
    func presentError(_ error: Error) {
        print("Episodes error:", error.localizedDescription)
    }
    
}
