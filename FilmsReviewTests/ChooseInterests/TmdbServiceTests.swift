//
//  TmdbServiceTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest
@testable import FilmsReview

final class TmdbServiceTests: XCTestCase {
    func testMergedGenreNamesUniquesAndSortsCaseInsensitive() async throws {
        let client = APIClientMock()
        client.stub["genre/movie/list"] = TMDBGenreListResponse(genres: [
            .init(id: 1, name: "drama"),
            .init(id: 2, name: "Action")
        ])
        client.stub["genre/tv/list"] = TMDBGenreListResponse(genres: [
            .init(id: 3, name: "Drama"),
            .init(id: 4, name: "Comedy")
        ])
        
        let service = TMDBService(client: client)
        let names = try await service.mergedGenreNames(language: "en")
        
        XCTAssertEqual(names, ["Action", "Comedy", "Drama"])
    }
    
    func testMergedGenreNamesHandlesEmptyResponses() async throws {
        let client = APIClientMock()
        client.stub["genre/movie/list"] = TMDBGenreListResponse(genres: [])
        client.stub["genre/tv/list"] = TMDBGenreListResponse(genres: [])
        
        let service = TMDBService(client: client)
        let names = try await service.mergedGenreNames(language: "en")
        
        XCTAssertEqual(names, [], "Ожидался пустой массив в случае, если сервер не вернул жанры")
    }
    
    func testMergedGenreNamesPropagatesError() async {
        let client = APIClientErrorMock()
        let service = TMDBService(client: client)
        
        do {
            _ = try await service.mergedGenreNames(language: "en")
            XCTFail("Ожидалась ошибка, но вернулся успешный результат")
        } catch {
            XCTAssertTrue(error is APIError,
                          "Ожидался APIError, но пришёл другой тип ошибки: \(error)")
        }
    }
    
}

private final class APIClientMock: APIClientProtocol {
    var stub: [String: TMDBGenreListResponse] = [:]

    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem],
        timeout: TimeInterval?
    ) async throws -> T {
        guard let response = stub[path] else {
            throw APIError.badResponse
        }

        return response as! T
    }
}

private final class APIClientErrorMock: APIClientProtocol {
    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem],
        timeout: TimeInterval?
    ) async throws -> T {
        throw APIError.http(code: 500, body: "Internal Server Error")
    }
}
