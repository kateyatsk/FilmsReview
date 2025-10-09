//
//  
//  MainTabBarPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import UIKit

protocol MainTabBarPresenterProtocol: PresenterProtocol {
    func prepareMoviesToBeDisplayed()
}

final class MainTabBarPresenter: MainTabBarPresenterProtocol {
    weak var viewController: ViewControllerProtocol?

    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }

    func prepareMoviesToBeDisplayed() {
        print("Prepare movies to be displayed")

        if let movieListVC = viewController as? HomeViewController {
        }
    }
}
