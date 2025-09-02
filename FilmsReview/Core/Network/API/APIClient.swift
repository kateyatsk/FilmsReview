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
    
    init(config: APIConfig, session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.config = config
        self.session = session
        self.decoder = decoder
    }
    
    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem] = [],
        timeout: TimeInterval? = nil
    ) async throws -> T {
        let timeoutValue = timeout ?? APIConstants.defaultTimeout
        
        guard var comps = URLComponents(
            url: config.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else { throw APIError.invalidURL }
        comps.queryItems = query.isEmpty ? nil : query
        guard let url = comps.url else { throw APIError.invalidURL }
        
        var req = URLRequest(url: url, timeoutInterval: timeoutValue)
        req.httpMethod = "GET"
        req.setValue(APIConstants.mimeJSON, forHTTPHeaderField: APIConstants.headerAccept)
        req.setValue(APIConstants.bearerPrefix + config.bearerToken, forHTTPHeaderField: APIConstants.headerAuthorization)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.badResponse }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.http(code: http.statusCode, body: body)
        }
        guard !data.isEmpty else { throw APIError.emptyData }
        return try decoder.decode(T.self, from: data)
    }
}
