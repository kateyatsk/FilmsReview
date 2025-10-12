//
//  HomeModels.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 23.09.25.
//


struct HomeModels {
    
    struct ViewModel {
        let recommended: [MediaItem]
        let topSearches: [MediaItem]
    }
    
    struct MediaListRequest {
        let title: String
        let items: [MediaItem]
    }
}
