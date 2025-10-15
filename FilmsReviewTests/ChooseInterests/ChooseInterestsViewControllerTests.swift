//
//  ChooseInterestsViewControllerTests.swift
//  FilmsReviewTests
//
//  Created by Екатерина Яцкевич on 29.08.25.
//

import XCTest
@testable import FilmsReview

final class ChooseInterestsViewControllerTests: XCTestCase {
    private var sut: ChooseInterestsViewController!
    private var interactor: InteractorSpy!

    override func setUp() {
        super.setUp()
        sut = ChooseInterestsViewController()
        interactor = InteractorSpy()
        sut.interactor = interactor
        _ = sut.view
    }

    func testDisplayGenresSetsDataAndReloadsCollection() {
        sut.displayGenres(["Action", "Drama"])
        XCTAssertEqual(numberOfItems(), 2)
    }

    func testSearchFiltersCollection() {
        sut.displayGenres(["Action", "Drama"])
        sut.searchBar(UISearchBar(), textDidChange: "dr")
        XCTAssertEqual(numberOfItems(), 1)
    }

    func testSelectItemTogglesSelectionAndReconfiguresCell() {
        sut.displayGenres(["Action"])
        let cv = collectionView()
        let index = IndexPath(item: 0, section: 0)
        cv.delegate?.collectionView?(cv, didSelectItemAt: index)
        let cell = cv.dataSource!.collectionView(cv, cellForItemAt: index) as! CategoryCell
        cell.layoutIfNeeded()
        let hasCheckmark = (cell.contentView.subviews.compactMap { ($0 as? UIButton)?.image(for: .normal) }).first != nil
        XCTAssertTrue(hasCheckmark)
    }

    func testTapNextCallsInteractorSaveFavoriteGenres() {
        sut.displayGenres(["Action"])
        let cv = collectionView()
        cv.delegate?.collectionView?(cv, didSelectItemAt: IndexPath(item: 0, section: 0))
        let next = sut.view.subviews.compactMap { $0 as? UIButton }.first(where: { $0.currentTitle == "Next" })!
        next.sendActions(for: .touchUpInside)
        XCTAssertEqual(interactor.savedGenres, ["Action"])
    }

    private func numberOfItems() -> Int {
        collectionView().dataSource?.collectionView(collectionView(), numberOfItemsInSection: 0) ?? -1
    }

    private func collectionView() -> UICollectionView {
        sut.view.subviews.compactMap { $0 as? UICollectionView }.first!
    }
}

private final class InteractorSpy: AuthenticationInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: AuthenticationWorkerProtocol { fatalError() }

    var savedGenres: [String] = []
    func saveFavoriteGenres(_ genres: [String]) { savedGenres = genres }
    func fetchTMDBGenres(language: String) {}
    func register(email: String, password: String) {}
    func login(email: String, password: String) {}
    func signOut(completion: @escaping (Error?) -> Void) {}
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {}
    func checkEmailVerified(completion: @escaping (Result<Bool, Error>) -> Void) {}
    func startEmailVerificationMonitoring() {}
    func stopEmailVerificationMonitoring() {}
    func deleteAccount(completion: @escaping (Error?) -> Void) {}
    func validateEmail(_ email: String) -> Bool { false }
    func resetPassword(email: String) {}
    func createProfile(name: String, birthday: Date, avatarData: Data?) {}
}

