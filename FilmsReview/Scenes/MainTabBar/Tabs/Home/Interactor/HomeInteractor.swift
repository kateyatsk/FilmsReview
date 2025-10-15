//
//
//  HomeInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol HomeInteractorProtocol: InteractorProtocol {
    func loadInitialContent()
    func getAllRecommended() -> [MediaItem]
    func getAllTopSearches() -> [MediaItem]
    func loadHeader()
    func loadNextMediaListPageIfNeeded(currentIndex: Int, source: MediaListSource)
}

private enum Constants {
    static let preloadThreshold = 3
    static let maxPages = 100
    static let firstPage = 1
    static let anonymousName = "Anonymous"
}

final class HomeInteractor: HomeInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: HomeWorkerProtocol
    
    private var currentRecommendedPage = Constants.firstPage
    private var isLoadingRecommended = false
    private var currentTopPage = Constants.firstPage
    private var isLoadingTop = false
    
    private var userPreferredGenres: [String] = []
    private var recommendedItems: [MediaItem] = []
    private var topSearchItems: [MediaItem] = []
    
    init(worker: HomeWorkerProtocol) {
        self.worker = worker
    }
    
    func loadInitialContent() {
        Task {
            do {
                let profile = await worker.fetchCurrentUserProfile()
                userPreferredGenres = profile?.favoriteGenres ?? []
                
                async let recommendedTask = worker.loadRecommendedContent(
                    userPreferredGenres: userPreferredGenres,
                    page: Constants.firstPage
                )
                async let topSearchesTask = worker.loadTopSearches(page: Constants.firstPage)
                
                let (recommended, topSearches) = try await (recommendedTask, topSearchesTask)
                
                recommendedItems = recommended
                topSearchItems = topSearches
                
                let viewModel = HomeModels.ViewModel(
                    recommended: recommended,
                    topSearches: topSearches
                )
                
                await MainActor.run {
                    (presenter as? HomePresenterProtocol)?
                        .presentContent(response: viewModel)
                }
            } catch {
                await MainActor.run {
                    (presenter as? HomePresenterProtocol)?
                        .presentError(error: error)
                }
            }
        }
    }
    
    func loadHeader() {
        Task {
            let profile = await worker.fetchCurrentUserProfile()
            let userName = (profile?.name
                .trimmingCharacters(in: .whitespacesAndNewlines))
                .flatMap { $0.isEmpty ? nil : $0 }
                ?? Constants.anonymousName
            let avatar = await worker.loadImage(profile?.avatarURL)
            
            await MainActor.run {
                (presenter as? HomePresenterProtocol)?
                    .presentHeader(name: userName, avatar: avatar)
            }
        }
    }
    
    func getAllRecommended() -> [MediaItem] { recommendedItems }
    
    func getAllTopSearches() -> [MediaItem] { topSearchItems }
    
    func loadNextMediaListPageIfNeeded(currentIndex: Int, source: MediaListSource) {
        switch source {
            
        case .recommendations:
            guard !isLoadingRecommended,
                  currentIndex >= recommendedItems.count - Constants.preloadThreshold,
                  currentRecommendedPage < Constants.maxPages else { return }
            
            isLoadingRecommended = true
            currentRecommendedPage += 1
            
            Task {
                defer { isLoadingRecommended = false }
                do {
                    let newItems = try await worker.loadRecommendedContent(
                        userPreferredGenres: userPreferredGenres,
                        page: currentRecommendedPage
                    )
                    guard !newItems.isEmpty else { return }
                    recommendedItems.append(contentsOf: newItems)
                    
                    await MainActor.run {
                        (presenter as? HomePresenterProtocol)?
                            .presentPaginated(items: recommendedItems)
                    }
                } catch {
                    print("Pagination error:", error)
                }
            }
            
        case .topSearch:
            guard !isLoadingTop,
                  currentIndex >= topSearchItems.count - Constants.preloadThreshold,
                  currentTopPage < Constants.maxPages else { return }
            
            isLoadingTop = true
            currentTopPage += 1
            
            Task {
                defer { isLoadingTop = false }
                do {
                    let newItems = try await worker.loadTopSearches(page: currentTopPage)
                    guard !newItems.isEmpty else { return }
                    topSearchItems.append(contentsOf: newItems)
                    
                    await MainActor.run {
                        (presenter as? HomePresenterProtocol)?
                            .presentPaginated(items: topSearchItems)
                    }
                } catch {
                    print("TopSearch pagination error:", error)
                }
            }
        }
    }
}
