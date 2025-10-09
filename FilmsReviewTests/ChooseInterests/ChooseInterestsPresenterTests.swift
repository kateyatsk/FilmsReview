//
//  ChooseInterestsPresenterTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest
@testable import FilmsReview

final class ChooseInterestsPresenterTests: XCTestCase {
    private var sut: AuthenticationPresenter!
    private var vc: ChooseInterestsVCSpy!

    override func setUp() {
        super.setUp()
        sut = AuthenticationPresenter()
        vc = ChooseInterestsVCSpy()
        sut.viewController = vc
        AppSettings.isAuthorized = false
    }

    override func tearDown() {
        AppSettings.isAuthorized = false
        sut = nil
        vc = nil
        super.tearDown()
    }

    func testDidStartLoadingGenresShowsLoading() {
        sut.didStartLoadingGenres()
        XCTAssertEqual(vc.loadingStates, [true])
    }

    func testDidLoadGenresHidesLoadingAndDisplaysNames() {
        sut.didLoadGenres(names: ["Action", "Drama"])
        XCTAssertEqual(vc.loadingStates, [false])
        XCTAssertEqual(vc.displayedGenres, ["Action", "Drama"])
    }

    func testDidStartSavingFavoriteGenresShowsLoading() {
        sut.didStartSavingFavoriteGenres()
        XCTAssertEqual(vc.loadingStates, [true])
    }

    func testDidSaveFavoriteGenresHidesLoadingSetsAuthorized() {
        sut.didSaveFavoriteGenres()
        XCTAssertEqual(vc.loadingStates, [false])
        XCTAssertTrue(AppSettings.isAuthorized)
    }
}

private enum TestError: Error { case any }

private final class ChooseInterestsVCSpy: UIViewController, ChooseInterestsVCProtocol {
    var interactor: (any FilmsReview.InteractorProtocol)?
    
    var loadingStates: [Bool] = []
    var displayedGenres: [String] = []
    var errors: [String] = []

    var router: (any RouterProtocol)?

    func displayLoading(_ isLoading: Bool) { loadingStates.append(isLoading) }
    func displayGenres(_ names: [String]) { displayedGenres = names }
    func showErrorAlert(_ message: String) { errors.append(message) }
}

