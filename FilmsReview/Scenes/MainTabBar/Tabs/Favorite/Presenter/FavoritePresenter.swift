//
//  
//  FavoritePresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol FavoritePresenterProtocol: PresenterProtocol {
    func setLoading(_ loading: Bool)
    func present(items: [MediaItem])
}

final class FavoritePresenter: FavoritePresenterProtocol {
    weak var viewController: ViewControllerProtocol?

    func setLoading(_ loading: Bool) {
        (viewController as? FavoriteVCProtocol)?.setLoading(loading)
    }

    func present(items: [MediaItem]) {
        (viewController as? FavoriteVCProtocol)?.show(items: items)
    }
}
