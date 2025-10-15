//
//  
//  SearchPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol SearchPresenterProtocol: PresenterProtocol {
    func presentTop(_ items: [MediaItem])
    func presentResults(_ items: [MediaItem])
    func presentError(_ error: Error)
}

final class SearchPresenter: SearchPresenterProtocol {
    weak var viewController: ViewControllerProtocol?

    func presentTop(_ items: [MediaItem]) {
        (viewController as? SearchVCProtocol)?.displayTop(items: items)
    }

    func presentResults(_ items: [MediaItem]) {
        (viewController as? SearchVCProtocol)?.displayResults(items: items)
    }

    func presentError(_ error: Error) {
        (viewController as? SearchVCProtocol)?.displayError(error)
    }
}
