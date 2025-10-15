//
//  TMDBModels.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

struct TMDBGenre: Codable, Hashable {
    let id: Int
    let name: String
}

struct TMDBGenreListResponse: Decodable {
    let genres: [TMDBGenre]
}

struct TMDBMultiDTO: Decodable {
    let mediaType: String?
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?   
    let backdropPath: String?
    let genreIds: [Int]?
}


struct Paged<T> {
    let results: [T]
    let page: Int
    let totalPages: Int
}

extension Paged: Decodable where T: Decodable {}


struct TMDBCastMember: Decodable {
    let id: Int?
    let name: String?
    let character: String?
    let profilePath: String?
}

struct TMDBCredits: Decodable {
    let cast: [TMDBCastMember]
}

struct TMDBReviewResponse: Decodable {
    let results: [TMDBReview]
}

struct TMDBReview: Decodable {
    let author: String?
    let content: String?
    let authorDetails: AuthorDetails?
    
    struct AuthorDetails: Decodable {
        let name: String?
        let username: String?
        let avatarPath: String?
        let rating: Double?
    }
}

struct TMDBMovieDetails: Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtime: Int?
    let genres: [TMDBGenre]?
}

struct TMDBTVDetails: Decodable {
    let id: Int
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    let genres: [TMDBGenre]?
    let voteAverage: Double?
    let numberOfSeasons: Int?
    let seasons: [TMDBSeasonSummary]?
}

struct TMDBSeasonSummary: Decodable {
    let seasonNumber: Int?
    let name: String?
    let episodeCount: Int?
}

struct TMDBSeasonDetails: Decodable {
    let id: Int?
    let seasonNumber: Int?
    let episodes: [TMDBEpisode]?
}

struct TMDBEpisode: Decodable {
    let id: Int?
    let episodeNumber: Int?
    let name: String?
    let overview: String?
    let runtime: Int?
    let stillPath: String?
}


