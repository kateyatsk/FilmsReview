//
//  AuthenticationWorkerTmdbTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest
@testable import FilmsReview

final class AuthenticationWorkerTmdbTests: XCTestCase {
    func testFetchTmdbGenresMergedPassthroughSuccess() {
        let tmdb = TMDBServiceStub(result: .success(["Action", "Drama"]))
        let sut = AuthenticationWorker(cloudinary: CloudinaryStub(), tmdb: tmdb)

        let exp = expectation(description: "genres")
        sut.fetchTMDBGenresMerged(language: "en") { result in
            let names = try? result.get()
            XCTAssertEqual(names, ["Action", "Drama"])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func testFetchTmdbGenresMergedFailure() {
        let tmdb = TMDBServiceStub(result: .failure(TestError.any))
        let sut = AuthenticationWorker(cloudinary: CloudinaryStub(), tmdb: tmdb)

        let exp = expectation(description: "genres")
        sut.fetchTMDBGenresMerged(language: "en") { result in
            switch result {
            case .success:
                XCTFail("expected failure")
            case .failure:
                XCTAssertTrue(true)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}

private enum TestError: Error { case any }

private struct TMDBServiceStub: TMDBServiceProtocol {
    let result: Result<[String], Error>

    func tvDetails(id: Int, language: String) async throws -> TMDBTVDetails {
        TMDBTVDetails(
            id: id,
            name: "Stub TV",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            firstAirDate: nil,
            genres: [],
            voteAverage: nil,
            numberOfSeasons: nil,
            seasons: []
        )
    }
    
    func movieDetails(id: Int, language: String) async throws -> TMDBMovieDetails {
        TMDBMovieDetails(
            id: id,
            title: "Stub Movie",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            runtime: nil,
            genres: []
        )
    }

    func trendingAll(window: TimeWindow, page: Int) async throws -> [TMDBMultiDTO] {
        return []
    }
    
    func discoverMoviesAndTv(movieGenreIDs: [Int], tvGenreIDs: [Int], page: Int) async throws -> [TMDBMultiDTO] {
        return []
    }
    
    func movieCredits(id: Int) async throws -> TMDBCredits {
        return TMDBCredits(cast: [])
    }
    
    func tvCredits(id: Int) async throws -> TMDBCredits {
        return TMDBCredits(cast: [])
    }
    
    func movieReviews(id: Int, page: Int) async throws -> [TMDBReview] {
        return []
    }
    
    func tvReviews(id: Int, page: Int) async throws -> [TMDBReview] {
        return []
    }
    
    func tvSeason(id: Int, seasonNumber: Int, language: String) async throws -> TMDBSeasonDetails {
        return TMDBSeasonDetails(id: id, seasonNumber: seasonNumber, episodes: nil)
    }

    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre] {
        return []
    }

    func mergedGenreNames(language: String) async throws -> [String] {
        return try result.get()
    }

    func searchMulti(query: String, page: Int, language: String) async throws -> [TMDBMultiDTO] {
        return []
    }
}

private struct CloudinaryStub: CloudinaryManaging {
    func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        completion(.success(URL(string: "https://example.com/avatar.png")!))
    }
}
