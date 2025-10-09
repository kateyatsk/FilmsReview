//
//  APIConstants.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

enum APIConstants {
    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let tmdbTokenPlistKey = "TMDBReadAccessToken"

    static let headerAccept = "Accept"
    static let headerAuthorization = "Authorization"
    static let mimeJSON = "application/json"
    static let bearerPrefix = "Bearer "

    static let defaultTimeout: TimeInterval = 20
}
