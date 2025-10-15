//
//  
//  FavoriteRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit
import Swinject

protocol FavoriteRouterProtocol: RouterProtocol {
    func openDetails(_ item: MediaItem, from: UIViewController)
}

final class FavoriteRouter: FavoriteRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?

    func openDetails(_ item: MediaItem, from: UIViewController) {
        guard let vc = DependencyContainer.shared.container.resolve(MovieDetailsViewController.self) else { return }
        vc.viewModel = item
        from.navigationController?.pushViewController(vc, animated: true)
    }
}
