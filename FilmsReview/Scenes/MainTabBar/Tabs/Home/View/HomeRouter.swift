//
//
//  HomeRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation
import Swinject
import UIKit

protocol HomeRouterProtocol: RouterProtocol {
    func showMediaList(title: String, items: [MediaItem], from: UIViewController)
    func showMovieDetails(vm: MediaItem)
}

final class HomeRouter: HomeRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func showMediaList(title: String, items: [MediaItem], from: UIViewController) {
        guard let vc = DependencyContainer.shared.container.resolve(MediaListViewController.self) else { return }
        vc.configure(title: title, items: items)
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMovieDetails(vm: MediaItem) {
        guard let vc = DependencyContainer.shared.container.resolve(MovieDetailsViewController.self) else { return }
        vc.viewModel = vm
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
