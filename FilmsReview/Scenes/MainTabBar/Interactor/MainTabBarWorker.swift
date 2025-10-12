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
    func fetchCast(for item: MediaItem) async throws -> [CastVM]
    func fetchReviews(for item: MediaItem, page: Int) async throws -> [ReviewVM]
    func fetchTVSeasonsSummary(tvId: Int) async throws -> (titles: [String], seasonNumbers: [Int])
    func fetchEpisodes(tvId: Int, seasonNumber: Int) async throws -> [EpisodeVM]
    func fetchSuggested(for item: MediaItem) async throws -> [MediaItem]
}

fileprivate enum Constants {
    static let maxCastCount = 20
    static let maxSuggestedCount = 5
    
    enum Text {
        static let unknownCastName = "Unknown"
        static let anonymousAuthor = "Anonymous"
        static let untitled = "Untitled"
        
        static let season = "Season"
        static let episode = "Episode"
        static let episodeTitleSeparator = ": "
        static let bullet = " • "
        static let episodesShortSuffix = " ep."
        static let minutesSuffix = " min"
        static let language = "en-US"
    }
}

final class MainTabBarWorker: MainTabBarWorkerProtocol {
    private let tmdb: TMDBServiceProtocol
    private let images: ImageLoaderProtocol
    
    init(tmdb: TMDBServiceProtocol, images: ImageLoaderProtocol) {
        self.tmdb = tmdb
        self.images = images
    }
    
    func fetchCast(for item: MediaItem) async throws -> [CastVM] {
        guard let id = item.tmdbId else { return [] }
        let credits: TMDBCredits = (item.mediaType == "tv")
        ? try await tmdb.tvCredits(id: id)
        : try await tmdb.movieCredits(id: id)
        
        return await withTaskGroup(of: CastVM?.self) { group in
            for castMember in credits.cast.prefix(Constants.maxCastCount) {
                group.addTask { [images] in
                    let profileURL = TMDBImages.profileURL(castMember.profilePath)
                    let image = await images.load(profileURL)
                    return CastVM(avatar: image, name: castMember.name ?? Constants.Text.unknownCastName)
                }
            }
            var result: [CastVM] = []
            for await viewModel in group { if let viewModel { result.append(viewModel) } }
            return result
        }
    }
    
    func fetchReviews(for item: MediaItem, page: Int = 1) async throws -> [ReviewVM] {
        guard let id = item.tmdbId else { return [] }
        
        let reviewDTOs: [TMDBReview] = (item.mediaType == "tv")
        ? try await tmdb.tvReviews(id: id, page: page)
        : try await tmdb.movieReviews(id: id, page: page)
        
        func nonEmptyTrimmed(_ string: String?) -> String? {
            guard let trimmed = string?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
            return trimmed
        }
        
        var result: [ReviewVM] = []
        result.reserveCapacity(reviewDTOs.count)
        
        for review in reviewDTOs {
            let authorName = nonEmptyTrimmed(review.authorDetails?.name)
            ?? nonEmptyTrimmed(review.authorDetails?.username)
            ?? nonEmptyTrimmed(review.author)
            ?? Constants.Text.anonymousAuthor
            
            let avatarURL = TMDBImages.reviewAvatarURL(review.authorDetails?.avatarPath)
            let avatarImage = await images.load(avatarURL)
            
            result.append(
                ReviewVM(
                    avatar: avatarImage,
                    author: authorName,
                    text: review.content ?? "",
                    rating: review.authorDetails?.rating
                )
            )
        }
        
        return result
    }
    
    func fetchSuggested(for item: MediaItem) async throws -> [MediaItem] {
        guard
            let id = item.tmdbId,
            let genreIds = item.genreIds,
            !genreIds.isEmpty
        else { return [] }
        
        let mixed: [TMDBMultiDTO] = try await tmdb.discoverMoviesAndTv(
            movieGenreIDs: (item.mediaType == "movie") ? genreIds : [],
            tvGenreIDs: (item.mediaType == "tv") ? genreIds : [],
            page: 1
        )
        
        let sameKind = mixed
            .filter { dto in
                let type = dto.mediaType ?? ((dto.firstAirDate != nil) ? "tv" : "movie")
                return type == item.mediaType && dto.id != id
            }
            .prefix(Constants.maxSuggestedCount)
        
        var result: [MediaItem] = []
        result.reserveCapacity(sameKind.count)
        
        for dto in sameKind {
            let title = dto.title ?? dto.name ?? Constants.Text.untitled
            let posterImage = await images.load(TMDBImages.posterURL(dto.posterPath))
            let backdropImage = await images.load(TMDBImages.backdropURL(dto.backdropPath) ?? TMDBImages.posterURL(dto.backdropPath))
            
            let viewModel = MediaItem(
                title: title,
                subtitle: "",
                poster: posterImage,
                backdrop: backdropImage,
                overview: dto.overview ?? "",
                metaChips: [],
                tmdbId: dto.id,
                mediaType: dto.mediaType ?? ((dto.firstAirDate != nil) ? "tv" : "movie"),
                genreIds: dto.genreIds
            )
            result.append(viewModel)
        }
        
        return result
    }
    
    func fetchTVSeasonsSummary(tvId: Int) async throws -> (titles: [String], seasonNumbers: [Int]) {
        let details = try await tmdb.tvDetails(id: tvId, language: Constants.Text.language)
        guard let rawSeasons = details.seasons, !rawSeasons.isEmpty else {
            return ([], [])
        }
        
        let sorted = rawSeasons.sorted {
            if $0.seasonNumber == 0 { return false }
            if $1.seasonNumber == 0 { return true }
            return ($0.seasonNumber ?? 0) < ($1.seasonNumber ?? 0)
        }
        
        let seasonNumbers = sorted.compactMap { $0.seasonNumber }
        let titles = sorted.map { season in
            let number = season.seasonNumber ?? 0
            let episodeCount = season.episodeCount ?? 0
            let trimmedName = season.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let seasonName = (trimmedName?.isEmpty == false) ? trimmedName! : "\(Constants.Text.season) \(number)"
            
            let episodesSuffix = episodeCount > 0
            ? "\(Constants.Text.bullet)\(episodeCount)\(Constants.Text.episodesShortSuffix)" : ""
            
            return seasonName + episodesSuffix
        }
        
        return (titles, seasonNumbers)
    }
    
    func fetchEpisodes(tvId: Int, seasonNumber: Int) async throws -> [EpisodeVM] {
        let season = try await tmdb.tvSeason(id: tvId, seasonNumber: seasonNumber, language: Constants.Text.language)
        let episodes = season.episodes ?? []
        
        var result: [EpisodeVM] = []
        result.reserveCapacity(episodes.count)
        
        for episode in episodes {
            let image = await images.load(TMDBImages.backdropURL(episode.stillPath))
            let episodeNumber = episode.episodeNumber ?? 0
            let rawName = episode.name ?? ""
            let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let baseTitle = "\(Constants.Text.episode) \(episodeNumber)"
            let title = name.isEmpty ? baseTitle : baseTitle + Constants.Text.episodeTitleSeparator + name
            
            let durationText = episode.runtime.map { "\($0)\(Constants.Text.minutesSuffix)" } ?? ""
            let overviewText = episode.overview ?? ""
            
            result.append(
                EpisodeVM(
                    image: image,
                    title: title,
                    duration: durationText,
                    episodeDescription: overviewText
                )
            )
        }
        
        return result
    }
}
