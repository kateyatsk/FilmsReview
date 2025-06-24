//
//  MovieListViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit

protocol MovieListDisplayLogic: AnyObject { }

final class MovieListViewController: UIViewController, MovieListDisplayLogic {
    var interactor: MovieListBusinessLogic?
    var router: (MovieListRoutingLogic & MovieListDataPassing)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        let viewController = self
        let interactor = MovieListInteractor()
        let presenter = MovieListPresenter()
        let router = MovieListRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}


