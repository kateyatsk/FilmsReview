//
//  TMDBEndpoints.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

enum TMDBMediaKind {
    case movie, tv
    
    var discoverPath: String {
        switch self {
        case .movie: return "discover/movie"
        case .tv: return "discover/tv"
        }
    }

    var genreListPath: String {
        switch self {
        case .movie: "genre/movie/list"
        case .tv: "genre/tv/list"
        }
    }
}

enum TimeWindow: String {
    case day
    case week
}
