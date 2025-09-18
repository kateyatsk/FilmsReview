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
    let overview: String
    let metaChips: [MetaChip]
    let seasonTitles: [String]
    let episodes: [EpisodeVM]
    let reviews: [ReviewVM]
    let suggested: [MediaItem]
    let cast: [CastVM]
    
    init(
        title: String,
        subtitle: String = "",
        poster: UIImage? = nil,
        genres: String = "",
        overview: String = "",
        metaChips: [MetaChip] = [],
        seasonTitles: [String] = [],
        episodes: [EpisodeVM] = [],
        reviews: [ReviewVM] = [],
        suggested: [MediaItem] = [],
        cast: [CastVM] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.poster = poster
        self.overview = overview
        self.metaChips = metaChips
        self.seasonTitles = seasonTitles
        self.episodes = episodes
        self.reviews = reviews
        self.suggested = suggested
        self.cast = cast
    }
    
    var genres: String {
        metaChips.compactMap {
            if case .genre(let g) = $0 { return g }
            return nil
        }.joined(separator: ", ")
    }
}

