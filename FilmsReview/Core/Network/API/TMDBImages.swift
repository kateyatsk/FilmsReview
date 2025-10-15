//
//  TMDBImages.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 20.09.25.
//

import UIKit

enum TMDBImages {
    static let baseURL = URL(string: "https://image.tmdb.org/t/p/")!
    static let posterSize = "w500"
    static let backdropSize = "w780"
    static let profileSize = "w185"

    static func posterURL(_ path: String?) -> URL? {
        makeImageURL(sizeIdentifier: posterSize, path: path)
    }

    static func backdropURL(_ path: String?) -> URL? {
        makeImageURL(sizeIdentifier: backdropSize, path: path)
    }

    static func profileURL(_ path: String?) -> URL? {
        makeImageURL(sizeIdentifier: profileSize, path: path)
    }

    static func reviewAvatarURL(_ path: String?) -> URL? {
        guard let normalized = normalizedPath(from: path) else { return nil }
        if normalized.hasPrefix("http://") || normalized.hasPrefix("https://") {
            return URL(string: normalized)
        }
        return makeImageURL(sizeIdentifier: profileSize, path: normalized)
    }

    private static func makeImageURL(sizeIdentifier: String, path: String?) -> URL? {
        guard let normalized = normalizedPath(from: path) else { return nil }
        return baseURL.appendingPathComponent(sizeIdentifier).appendingPathComponent(normalized)
    }

    private static func normalizedPath(from rawPath: String?) -> String? {
        guard let trimmed = rawPath?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        let withoutLeadingSlashes = trimmed.drop(while: { $0 == "/" })
        return withoutLeadingSlashes.isEmpty ? nil : String(withoutLeadingSlashes)
    }
}

protocol ImageLoaderProtocol {
    func load(_ url: URL?) async -> UIImage?
}

final class ImageLoader: ImageLoaderProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func load(_ url: URL?) async -> UIImage? {
        guard let url else { return nil }
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { return nil }
            if let mimeType = response.mimeType, !mimeType.hasPrefix("image/") { return nil }
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
