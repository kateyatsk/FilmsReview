//
//  MovieListPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

protocol MovieListPresentationLogic {}

final class MovieListPresenter: MovieListPresentationLogic {
    weak var viewController: MovieListDisplayLogic?

}
