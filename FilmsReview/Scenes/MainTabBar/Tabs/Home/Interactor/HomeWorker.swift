//
//  HomeWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation
import UIKit

protocol HomeWorkerProtocol {
    func loadRecommendedContent(userPreferredGenres: [String], page: Int) async throws -> [MediaItem]
    func fetchCurrentUserProfile() async -> UserProfile?
    func loadImage(_ url: URL?) async -> UIImage?
    func loadTopSearches(page: Int) async throws -> [MediaItem]
}

fileprivate enum Constants {
    static let languageENUS = "en-US"
    static let unknownTitle = "Untitled"
    static let yearPrefixLength = 4
    static let recommendedGenresLimit = 3
    static let topSearchGenresLimit = 2
    static let fallbackGenresCount = 5
}

final class HomeWorker: HomeWorkerProtocol {
    private let tmdbService: TMDBServiceProtocol
    private let images: ImageLoaderProtocol
    
    init(tmdbService: TMDBServiceProtocol, images: ImageLoaderProtocol) {
        self.tmdbService = tmdbService
        self.images = images
    }
    
    func loadRecommendedContent(userPreferredGenres: [String], page: Int = 1) async throws -> [MediaItem] {
        let movieGenres = try await tmdbService.genres(kind: .movie, language: Constants.languageENUS)
        let tvGenres = try await tmdbService.genres(kind: .tv, language: Constants.languageENUS)
        let movieDict = Dictionary(uniqueKeysWithValues: movieGenres.map { ($0.id, $0.name) })
        let tvDict = Dictionary(uniqueKeysWithValues: tvGenres.map { ($0.id, $0.name) })
        
        func ids(_ names: [String], in all: [TMDBGenre]) -> [Int] {
            let set = Set(names.map { $0.lowercased() })
            return all.filter { set.contains($0.name.lowercased()) }.map(\.id)
        }
        
        let chosenGenreNames: [String] = {
            guard userPreferredGenres.isEmpty else { return userPreferredGenres }
            let allNames = Array(Set((movieGenres + tvGenres).map { $0.name }))
            return Array(allNames.shuffled().prefix(Constants.fallbackGenresCount))
        }()
        
        let movieIDs = ids(chosenGenreNames, in: movieGenres)
        let tvIDs = ids(chosenGenreNames, in: tvGenres)
        
        let mixed = try await tmdbService.discoverMoviesAndTv(
            movieGenreIDs: movieIDs,
            tvGenreIDs: tvIDs,
            page: page
        )
        
        var items: [MediaItem] = []
        for dto in mixed {
            let title = dto.title ?? dto.name ?? Constants.unknownTitle
            let poster = await images.load(TMDBImages.posterURL(dto.posterPath))
            let backdrop = await images.load(TMDBImages.backdropURL(dto.backdropPath))
            
            let releaseYear: String? = {
                if let dateString = dto.releaseDate {
                    return String(dateString.prefix(Constants.yearPrefixLength))
                }
                if let dateString = dto.firstAirDate {
                    return String(dateString.prefix(Constants.yearPrefixLength))
                }
                return nil
            }()
            
            let genresSubtitle: String = {
                let genreDict = (dto.mediaType == "tv") ? tvDict : movieDict
                let names = (dto.genreIds ?? []).compactMap { genreDict[$0] }
                return names.isEmpty ? "" : names.prefix(Constants.recommendedGenresLimit).joined(separator: ", ")
            }()
            
            var chips: [MetaChip] = []
            if let year = releaseYear { chips.append(.year(year)) }
            
            items.append(.init(
                title: title,
                subtitle: genresSubtitle,
                poster: poster,
                backdrop: backdrop,
                overview: dto.overview ?? "",
                metaChips: chips,
                tmdbId: dto.id,
                mediaType: dto.mediaType ?? (dto.firstAirDate != nil ? "tv" : "movie"),
                genreIds: dto.genreIds
            ))
        }
        
        return items
    }
    
    func loadTopSearches(page: Int) async throws -> [MediaItem] {
        let mixed = try await tmdbService.trendingAll(window: .day, page: page)
        
        async let movieGenresTask = tmdbService.genres(kind: .movie, language: Constants.languageENUS)
        async let tvGenresTask = tmdbService.genres(kind: .tv, language: Constants.languageENUS)
        let (movieGenres, tvGenres) = try await (movieGenresTask, tvGenresTask)
        let movieDict = Dictionary(uniqueKeysWithValues: movieGenres.map { ($0.id, $0.name) })
        let tvDict = Dictionary(uniqueKeysWithValues: tvGenres.map { ($0.id, $0.name) })
        
        var items: [MediaItem] = []
        for dto in mixed {
            let title = dto.title ?? dto.name ?? Constants.unknownTitle
            let poster = await images.load(TMDBImages.posterURL(dto.posterPath))
            let backdrop = await images.load(
                TMDBImages.backdropURL(dto.backdropPath) ?? TMDBImages.posterURL(dto.backdropPath)
            )
            
            let releaseYear: String? = {
                if let dateString = dto.releaseDate {
                    return String(dateString.prefix(Constants.yearPrefixLength))
                }
                if let dateString = dto.firstAirDate {
                    return String(dateString.prefix(Constants.yearPrefixLength))
                }
                return nil
            }()
            
            let chips: [MetaChip] = releaseYear.map { [.year($0)] } ?? []
            
            let genreDict = (dto.mediaType == "tv") ? tvDict : movieDict
            let genres = (dto.genreIds ?? []).compactMap { genreDict[$0] }
            let subtitle = genres.isEmpty ? "" : genres.prefix(Constants.topSearchGenresLimit).joined(separator: ", ")
            
            items.append(.init(
                title: title,
                subtitle: subtitle,
                poster: poster,
                backdrop: backdrop,
                overview: dto.overview ?? "",
                metaChips: chips,
                tmdbId: dto.id,
                mediaType: dto.mediaType ?? (dto.firstAirDate != nil ? "tv" : "movie"),
                genreIds: dto.genreIds
            ))
        }
        return items
    }
    
    func fetchCurrentUserProfile() async -> UserProfile? {
        guard let uid = FirebaseAuthManager.shared.getCurrentUID() else { return nil }
        return await FirestoreManager.shared.fetchUserProfile(uid: uid)
    }
    
    func loadImage(_ url: URL?) async -> UIImage? {
        await images.load(url)
    }
}
