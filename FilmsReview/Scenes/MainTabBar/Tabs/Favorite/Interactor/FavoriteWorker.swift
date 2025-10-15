//
//  
//  FavoriteWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation
import UIKit
import FirebaseFirestore

protocol FavoriteWorkerProtocol {
    func loadFavorites(uid: String) async throws -> [MediaItem]
    func toggleFavorite(uid: String, item: MediaItem, isFavorite: Bool) async throws
    func isFavorite(uid: String, item: MediaItem) async throws -> Bool
}

final class FavoriteWorker: FavoriteWorkerProtocol {
    private let tmdb: TMDBServiceProtocol
    private let imageLoader: ImageLoaderProtocol

    init(tmdb: TMDBServiceProtocol, imageLoader: ImageLoaderProtocol = ImageLoader()) {
        self.tmdb = tmdb
        self.imageLoader = imageLoader
    }

    private func userRef(_ uid: String) -> DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }

    func loadFavorites(uid: String) async throws -> [MediaItem] {
        let snap = try await userRef(uid).getDocument()
        let raw = (snap.data()?["favorites"] as? [String]) ?? []
        let keys = raw.compactMap(FavoriteKey.init(raw:))

        var items: [MediaItem] = []
        items.reserveCapacity(keys.count)

        for key in keys {
            switch key.type {
            case .movie:
                let d = try await tmdb.movieDetails(id: key.id, language: "en-US")

                async let posterImg = imageLoader.load(TMDBImages.posterURL(d.posterPath))
                async let backdropImg = imageLoader.load(TMDBImages.backdropURL(d.backdropPath))
                let (poster, backdrop) = await (posterImg, backdropImg)

                let genreNames = (d.genres ?? []).map { $0.name }
                let subtitle = genreNames.isEmpty ? "" : genreNames.prefix(3).joined(separator: ", ")

                items.append(
                    MediaItem(
                        title: d.title,
                        subtitle: subtitle,
                        poster: poster,
                        backdrop: backdrop,
                        overview: d.overview ?? "",
                        metaChips: [],
                        tmdbId: d.id,
                        mediaType: "movie",
                        genreIds: d.genres?.map(\.id)
                    )
                )

            case .tv:
                let d = try await tmdb.tvDetails(id: key.id, language: "en-US")

                async let posterImg = imageLoader.load(TMDBImages.posterURL(d.posterPath))
                async let backdropImg = imageLoader.load(TMDBImages.backdropURL(d.backdropPath))
                let (poster, backdrop) = await (posterImg, backdropImg)

                let genreNames = (d.genres ?? []).map { $0.name }
                let subtitle = genreNames.isEmpty ? "" : genreNames.prefix(3).joined(separator: ", ")

                items.append(
                    MediaItem(
                        title: d.name ?? "Untitled",
                        subtitle: subtitle,             
                        poster: poster,
                        backdrop: backdrop,
                        overview: d.overview ?? "",
                        metaChips: [],
                        tmdbId: d.id,
                        mediaType: "tv",
                        genreIds: d.genres?.map(\.id)
                    )
                )
            }
        }

        return items
    }



    func toggleFavorite(uid: String, item: MediaItem, isFavorite: Bool) async throws {
        guard let id = item.tmdbId,
              let type = item.mediaType else {
            return
        }
        let key = FavoriteKey(mediaType: type, id: id).raw

        try await userRef(uid).updateData([
            "favorites": isFavorite
                ? FieldValue.arrayUnion([key])
                : FieldValue.arrayRemove([key])
        ])
    }

    func isFavorite(uid: String, item: MediaItem) async throws -> Bool {
        guard let id = item.tmdbId,
              let type = item.mediaType else {
            return false
        }
        let key = FavoriteKey(mediaType: type, id: id).raw
        let snap = try await userRef(uid).getDocument()
        let arr = (snap.data()?["favorites"] as? [String]) ?? []
        return arr.contains(key)
    }

}
