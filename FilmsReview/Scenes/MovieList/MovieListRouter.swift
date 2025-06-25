//
//  MovieListRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import Foundation
import Swinject
import UIKit

protocol MovieListRouterProtocol: RouterProtocol {
    func navigateToDetail()
}

final class MovieListRouter: MovieListRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func navigateToDetail() {
        print("navigated to details")
    }
}
