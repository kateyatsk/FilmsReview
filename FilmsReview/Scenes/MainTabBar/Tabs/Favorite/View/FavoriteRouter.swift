//
//  
//  FavoriteRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation
import Swinject
import UIKit

protocol FavoriteRouterProtocol: RouterProtocol {
    func navigateToDetail()
}

final class FavoriteRouter: FavoriteRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?

    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }

    func navigateToDetail() {
        print("navigated to details")
    }
}
