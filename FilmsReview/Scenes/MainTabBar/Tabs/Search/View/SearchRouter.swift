//
//  
//  SearchRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation
import Swinject
import UIKit

protocol SearchRouterProtocol: RouterProtocol {
    func navigateToDetail()
}

final class SearchRouter: SearchRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?

    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }

    func navigateToDetail() {
        print("navigated to details")
    }
}
