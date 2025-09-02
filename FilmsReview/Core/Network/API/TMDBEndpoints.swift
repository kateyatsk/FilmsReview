//
//  TMDBEndpoints.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

enum TMDBMediaKind {
    case movie, tv

    var path: String {
        switch self {
        case .movie: "genre/movie/list"
        case .tv:    "genre/tv/list"
        }
    }
}
