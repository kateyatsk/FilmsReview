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
    func openDetails(_ item: MediaItem, from: UIViewController)
}

final class SearchRouter: SearchRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?

    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }

    func openDetails(_ item: MediaItem, from: UIViewController) {
        guard let vc = DependencyContainer.shared.container.resolve(MovieDetailsViewController.self) else { return }
        vc.viewModel = item
        from.navigationController?.pushViewController(vc, animated: true)
    }
}
