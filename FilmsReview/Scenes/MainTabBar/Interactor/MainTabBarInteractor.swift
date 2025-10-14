//
//
//  MainTabBarInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import Foundation

protocol MainTabBarInteractorProtocol: InteractorProtocol {
    func loadCast(for item: MediaItem)
    func loadReviews(for item: MediaItem)
    func loadSuggested(for item: MediaItem)
    func loadTVInitial(for item: MediaItem)
    func loadTVSeason(for item: MediaItem, seasonIndex: Int)
    func readFavoriteStatus(for item: MediaItem, completion: @escaping (Bool) -> Void)
    func updateFavorite(isLiked: Bool, for item: MediaItem)
}

final class MainTabBarInteractor: MainTabBarInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: MainTabBarWorkerProtocol
    
    private var currentSeasonNumbers: [Int] = []
    
    init(presenter: MainTabBarPresenter? = nil, worker: MainTabBarWorkerProtocol) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func loadCast(for item: MediaItem) {
        Task {
            do {
                let cast = try await worker.fetchCast(for: item)
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentCast(cast)
                }
            } catch {
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
    
    func loadReviews(for item: MediaItem) {
        Task {
            do {
                let reviews = try await worker.fetchReviews(for: item, page: 1)
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentReviews(reviews)
                }
            } catch {
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
    
    func loadSuggested(for item: MediaItem) {
        Task {
            do {
                let suggested = try await worker.fetchSuggested(for: item)
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentSuggested(suggested)
                }
            } catch {
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
    
    func loadTVInitial(for item: MediaItem) {
        guard item.mediaType == "tv", let id = item.tmdbId else { return }
        Task {
            do {
                let (titles, seasonNumbers) = try await worker.fetchTVSeasonsSummary(tvId: id)
                self.currentSeasonNumbers = seasonNumbers
                
                let initialIndex = 0
                let seasonNumber = seasonNumbers.indices.contains(initialIndex) ? seasonNumbers[initialIndex] : 1
                
                let episodes = try await worker.fetchEpisodes(tvId: id, seasonNumber: seasonNumber)
                
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?
                        .presentTVSeasons(titles: titles, selectedIndex: initialIndex, episodes: episodes)
                }
            } catch {
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
    
    func loadTVSeason(for item: MediaItem, seasonIndex: Int) {
        guard item.mediaType == "tv", let id = item.tmdbId else { return }
        let seasonNumber = currentSeasonNumbers.indices.contains(seasonIndex) ? currentSeasonNumbers[seasonIndex] : (seasonIndex + 1)
        Task {
            do {
                let episodes = try await worker.fetchEpisodes(tvId: id, seasonNumber: seasonNumber)
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?
                        .presentTVSeasonEpisodes(episodes: episodes, selectedIndex: seasonIndex)
                }
            } catch {
                await MainActor.run {
                    (presenter as? MainTabBarPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
    
    func readFavoriteStatus(for item: MediaItem, completion: @escaping (Bool) -> Void) {
        Task {
            let isLiked = await worker.fetchFavoriteStatus(for: item)
            await MainActor.run { completion(isLiked) }
        }
    }
    
    func updateFavorite(isLiked: Bool, for item: MediaItem) {
        Task { await worker.writeFavorite(isLiked: isLiked, for: item) }
    }
    
}
