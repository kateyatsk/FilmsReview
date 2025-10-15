//
//  FavoriteMediaType.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 14.10.25.
//

enum FavoriteMediaType: String { case movie, tv }

struct FavoriteKey {
    let type: FavoriteMediaType
    let id: Int

    var raw: String { "\(type.rawValue):\(id)" }

    init?(raw: String) {
        let parts = raw.split(separator: ":")
        guard parts.count == 2,
              let type = FavoriteMediaType(rawValue: String(parts[0])),
              let id = Int(parts[1]) else { return nil }
        self.type = type
        self.id = id
    }

    init(mediaType: String, id: Int) {
        self.type = (mediaType == "tv") ? .tv : .movie
        self.id = id
    }
}
