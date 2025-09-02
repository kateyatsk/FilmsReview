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

    func genres(kind: TMDBMediaKind, language: String) async throws -> [TMDBGenre] {
        return []
    }

    func mergedGenreNames(language: String) async throws -> [String] {
        return try result.get()
    }
}

private struct CloudinaryStub: CloudinaryManaging {
    func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        completion(.success(URL(string: "https://example.com/avatar.png")!))
    }
}
