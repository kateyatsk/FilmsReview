//
//  APIConfig.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 26.08.25.
//

import Foundation

struct APIConfig {
    let baseURL: URL
    let bearerToken: String

    init(baseURL: URL, bearerToken: String) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
    }

    static func tmdbFromPlist() throws -> APIConfig {
        guard let base = URL(string: APIConstants.tmdbBaseURL) else { throw APIError.invalidBaseURL }
        guard let token = Bundle.main.object(forInfoDictionaryKey: APIConstants.tmdbTokenPlistKey) as? String,
              !token.isEmpty else { throw APIError.missingToken }
        return .init(baseURL: base, bearerToken: token)
    }
}
