//
//  TMDBModels.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

struct TMDBGenre: Decodable, Hashable {
    public let id: Int
    public let name: String
}

struct TMDBGenreListResponse: Decodable {
    let genres: [TMDBGenre]
}
