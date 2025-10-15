//
//  APIClient.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

protocol APIClientProtocol {
    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem],
        timeout: TimeInterval?
    ) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let config: APIConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        config: APIConfig,
        session: URLSession = .shared,
        decoder: JSONDecoder = .init()
    ) {
        self.config = config
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem] = [],
        timeout: TimeInterval? = nil
    ) async throws -> T {
        let effectiveTimeout = timeout ?? APIConstants.defaultTimeout

        guard var components = URLComponents(
            url: config.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        components.queryItems = query.isEmpty ? nil : query

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: effectiveTimeout)
        request.httpMethod = "GET"
        request.setValue(APIConstants.mimeJSON, forHTTPHeaderField: APIConstants.headerAccept)
        request.setValue(APIConstants.bearerPrefix + config.bearerToken,
                         forHTTPHeaderField: APIConstants.headerAuthorization)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.badResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.http(code: httpResponse.statusCode, body: body)
        }
        guard !data.isEmpty else {
            throw APIError.emptyData
        }

        return try decoder.decode(T.self, from: data)
    }
}
