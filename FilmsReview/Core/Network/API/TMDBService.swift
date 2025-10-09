//
//  TMDBServiceProtocol.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 27.08.25.
//

import Foundation

protocol TMDBServiceProtocol {
    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre]
    func mergedGenreNames(language: String) async throws -> [String]
}

final class TMDBService: TMDBServiceProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) { self.client = client }

    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre] {
        let q = [URLQueryItem(name: "language", value: language)]
        let dto: TMDBGenreListResponse = try await client.get(kind.path, query: q, timeout: nil)
        return dto.genres
    }

    func mergedGenreNames(language: String) async throws -> [String] {
        async let movie = genres(kind: .movie, language: language)
        async let tv = genres(kind: .tv, language: language)
        let (m, t) = try await (movie, tv)

        let all = m.map(\.name) + t.map(\.name)

        var seen = Set<String>()
        var unique: [String] = []

        for name in all {
            let key = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            if !seen.contains(key) {
                seen.insert(key)
                let capitalized = name.prefix(1).uppercased() + name.dropFirst().lowercased()
                unique.append(capitalized)
            }
        }

        return unique.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }
}
