//
//  
//  SearchWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

fileprivate enum Constants {
    static let languageENUS = "en-US"
    static let genresLimit = 3
}

protocol SearchWorkerProtocol {
    func loadTopSearches(page: Int) async throws -> [MediaItem]
    func searchItems(query: String, page: Int) async throws -> [MediaItem]
}

final class SearchWorker: SearchWorkerProtocol {
    private let tmdb: TMDBServiceProtocol
    private let images: ImageLoaderProtocol

    init(tmdb: TMDBServiceProtocol, images: ImageLoaderProtocol) {
        self.tmdb = tmdb
        self.images = images
    }

    func loadTopSearches(page: Int) async throws -> [MediaItem] {
        let dtos = try await tmdb.trendingAll(window: .day, page: page)
        return try await mapToMediaItems(dtos)
    }

    func searchItems(query: String, page: Int) async throws -> [MediaItem] {
        try Task.checkCancellation()
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        let dtos = try await tmdb.searchMulti(query: query, page: page, language: Constants.languageENUS)
        try Task.checkCancellation()
        return try await mapToMediaItems(dtos)
    }

    private func inferType(_ dto: TMDBMultiDTO) -> String {
        dto.mediaType ?? (dto.firstAirDate != nil ? "tv" : "movie")
    }

    private func mapToMediaItems(_ dtos: [TMDBMultiDTO]) async throws -> [MediaItem] {
        async let movieGenresTask = tmdb.genres(kind: .movie, language: Constants.languageENUS)
        async let tvGenresTask    = tmdb.genres(kind: .tv, language: Constants.languageENUS)
        let (movieGenres, tvGenres) = try await (movieGenresTask, tvGenresTask)

        let movieDict = Dictionary(uniqueKeysWithValues: movieGenres.map { ($0.id, $0.name) })
        let tvDict = Dictionary(uniqueKeysWithValues: tvGenres.map { ($0.id, $0.name) })

        var out: [MediaItem] = []
        out.reserveCapacity(dtos.count)

        for dto in dtos {
            let title = dto.title ?? dto.name ?? "Untitled"
            let poster = await images.load(TMDBImages.posterURL(dto.posterPath))
            let backdrop = await images.load(
                TMDBImages.backdropURL(dto.backdropPath) ?? TMDBImages.posterURL(dto.backdropPath)
            )

            let year: String? = {
                if let d = dto.releaseDate { return String(d.prefix(4)) }
                if let d = dto.firstAirDate { return String(d.prefix(4)) }
                return nil
            }()
            let chips: [MetaChip] = year.map { [.year($0)] } ?? []

            let type = inferType(dto)
            let dict = (type == "tv") ? tvDict : movieDict
            let genreNames = (dto.genreIds ?? []).compactMap { dict[$0] }
            let subtitle = genreNames.isEmpty ? "" : genreNames.prefix(Constants.genresLimit).joined(separator: ", ")

            out.append(.init(
                title: title,
                subtitle: subtitle,
                poster: poster,
                backdrop: backdrop,
                overview: dto.overview ?? "",
                metaChips: chips,
                tmdbId: dto.id,
                mediaType: type,
                genreIds: dto.genreIds
            ))
        }
        return out
    }
}

final class Debouncer {
    private var task: Task<Void, Never>?

    func schedule(after delay: TimeInterval, action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
