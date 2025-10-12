//
//  MediaItem.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.09.25.
//

import UIKit

struct MediaItem {
    let title: String
    let subtitle: String
    let poster: UIImage?
    let backdrop: UIImage?
    let overview: String
    let metaChips: [MetaChip]
    var seasonTitles: [String]
    var episodes: [EpisodeVM]
    var reviews: [ReviewVM]
    var suggested: [MediaItem]
    var cast: [CastVM]
    let tmdbId: Int?
    let mediaType: String?
    let genreIds: [Int]?
    
    init(
        title: String,
        subtitle: String = "",
        poster: UIImage? = nil,
        backdrop: UIImage? = nil,
        genres: String = "",
        overview: String = "",
        metaChips: [MetaChip] = [],
        seasonTitles: [String] = [],
        episodes: [EpisodeVM] = [],
        reviews: [ReviewVM] = [],
        suggested: [MediaItem] = [],
        cast: [CastVM] = [],
        tmdbId: Int? = nil,
        mediaType: String? = nil,
        genreIds: [Int]? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.poster = poster
        self.backdrop = backdrop
        self.overview = overview
        self.metaChips = metaChips
        self.seasonTitles = seasonTitles
        self.episodes = episodes
        self.reviews = reviews
        self.suggested = suggested
        self.cast = cast
        self.tmdbId = tmdbId
        self.mediaType = mediaType
        self.genreIds = genreIds
    }
    
}

