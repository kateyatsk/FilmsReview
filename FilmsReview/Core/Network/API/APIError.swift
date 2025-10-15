//
//  APIError.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidBaseURL
    case missingToken
    case invalidURL
    case badResponse
    case http(code: Int, body: String)
    case emptyData

    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL: "Invalid base URL."
        case .missingToken:   "TMDB token is missing (add \(APIConstants.tmdbTokenPlistKey) to Info.plist)."
        case .invalidURL:     "Failed to build request URL."
        case .badResponse:    "Bad server response."
        case .http(let c, let b): "HTTP \(c). \(b)"
        case .emptyData:      "Empty response data."
        }
    }
}
