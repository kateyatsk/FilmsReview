//
//  TMDBServiceProtocol.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

protocol TMDBServiceProtocol {
    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre]
    func mergedGenreNames(language: String) async throws -> [String]
    
    func trendingAll(window: TimeWindow, page: Int) async throws -> [TMDBMultiDTO]
    func discoverMoviesAndTv(movieGenreIDs: [Int], tvGenreIDs: [Int], page: Int) async throws -> [TMDBMultiDTO]
    
    func movieCredits(id: Int) async throws -> TMDBCredits
    func tvCredits(id: Int) async throws -> TMDBCredits
    
    func movieReviews(id: Int, page: Int) async throws -> [TMDBReview]
    func tvReviews(id: Int, page: Int) async throws -> [TMDBReview]
    
    func tvDetails(id: Int, language: String) async throws -> TMDBTVDetails
    func tvSeason(id: Int, seasonNumber: Int, language: String) async throws -> TMDBSeasonDetails
}

final class TMDBService: TMDBServiceProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol) { self.client = client }
    
    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre] {
        let queryItems = [URLQueryItem(name: "language", value: language)]
        let response: TMDBGenreListResponse = try await client.get(kind.genreListPath, query: queryItems, timeout: nil)
        return response.genres
    }
    
    func mergedGenreNames(language: String) async throws -> [String] {
        async let movieGenres = genres(kind: .movie, language: language)
        async let tvGenres = genres(kind: .tv, language: language)
        let (movieGenresList, tvGenresList) = try await (movieGenres, tvGenres)

        let combinedNames = movieGenresList.map(\.name) + tvGenresList.map(\.name)
        
        var seen = Set<String>()
        var unique: [String] = []
        
        for name in combinedNames {
            let key = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            if !seen.contains(key) {
                seen.insert(key)
                let normalized = name.prefix(1).uppercased() + name.dropFirst().lowercased()
                unique.append(normalized)
            }
        }
        
        return unique.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }
    
    func trendingAll(window: TimeWindow, page: Int) async throws -> [TMDBMultiDTO] {
        let queryItems = [URLQueryItem(name: "page", value: String(max(1, page)))]
        let pageResponse: Paged<TMDBMultiDTO> = try await client.get("trending/all/\(window.rawValue)", query: queryItems, timeout: nil)
        return pageResponse.results.filter { $0.mediaType == "movie" || $0.mediaType == "tv" }
    }
    
    func discover(kind: TMDBMediaKind, genreIDs: [Int], page: Int = 1) async throws -> [TMDBMultiDTO] {
        var queryItems: [URLQueryItem] = [.init(name: "page", value: String(max(1, page)))]
        if !genreIDs.isEmpty {
            queryItems.append(.init(name: "with_genres", value: genreIDs.map(String.init).joined(separator: ",")))
        }
        
        let pageResponse: Paged<TMDBMultiDTO> = try await client.get(kind.discoverPath, query: queryItems, timeout: nil)
        
        let mediaTag = (kind == .movie) ? "movie" : "tv"
        return pageResponse.results.map { item in
            TMDBMultiDTO(
                mediaType: item.mediaType ?? mediaTag,
                id: item.id,
                title: item.title,
                name: item.name,
                overview: item.overview,
                posterPath: item.posterPath,
                releaseDate: item.releaseDate,
                firstAirDate: item.firstAirDate,
                backdropPath: item.backdropPath,
                genreIds: item.genreIds
            )
        }
    }
    
    func discoverMoviesAndTv(movieGenreIDs: [Int], tvGenreIDs: [Int], page: Int = 1) async throws -> [TMDBMultiDTO] {
        async let movies  = discover(kind: .movie, genreIDs: movieGenreIDs, page: page)
        async let tvShows = discover(kind: .tv, genreIDs: tvGenreIDs,    page: page)
        let (movieResults, tvResults) = try await (movies, tvShows)
        return movieResults + tvResults
    }
    
    func movieCredits(id: Int) async throws -> TMDBCredits {
        try await client.get("movie/\(id)/credits", query: [], timeout: nil)
    }
    
    func tvCredits(id: Int) async throws -> TMDBCredits {
        try await client.get("tv/\(id)/credits", query: [], timeout: nil)
    }
    
    func movieReviews(id: Int, page: Int = 1) async throws -> [TMDBReview] {
        let queryItems = [URLQueryItem(name: "page", value: String(max(1, page)))]
        let response: TMDBReviewResponse = try await client.get("movie/\(id)/reviews", query: queryItems, timeout: nil)
        return response.results
    }
    
    func tvReviews(id: Int, page: Int = 1) async throws -> [TMDBReview] {
        let queryItems = [URLQueryItem(name: "page", value: String(max(1, page)))]
        let response: TMDBReviewResponse = try await client.get("tv/\(id)/reviews", query: queryItems, timeout: nil)
        return response.results
    }
    
    func tvDetails(id: Int, language: String = "en-US") async throws -> TMDBTVDetails {
        let queryItems = [URLQueryItem(name: "language", value: language)]
        return try await client.get("tv/\(id)", query: queryItems, timeout: nil)
    }
    
    func tvSeason(id: Int, seasonNumber: Int, language: String = "en-US") async throws -> TMDBSeasonDetails {
        let queryItems = [URLQueryItem(name: "language", value: language)]
        return try await client.get("tv/\(id)/season/\(seasonNumber)", query: queryItems, timeout: nil)
    }
}
