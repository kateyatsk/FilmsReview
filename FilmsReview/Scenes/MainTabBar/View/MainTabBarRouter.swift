//
//
//  MainTabBarRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import Foundation
import Swinject
import UIKit

protocol MainTabBarRouterProtocol: RouterProtocol {
    func openDetails(for item: MediaItem, from: UIViewController)
    func showMovieDetails(vm: MediaItem)
}

final class MainTabBarRouter: MainTabBarRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func openDetails(for item: MediaItem, from: UIViewController) {
        guard let vc = DependencyContainer.shared.container.resolve(MovieDetailsViewController.self) else {
            fatalError("DI: resolve MovieDetailsViewController failed")
        }
        vc.viewModel = item
        
        guard let nav = from.navigationController else {
            fatalError("NavigationController is nil")
        }
        nav.pushViewController(vc, animated: true)
    }
    
    func showMovieDetails(vm: MediaItem) {
        guard let vc = DependencyContainer.shared.container.resolve(MovieDetailsViewController.self) else { return }
        vc.viewModel = vm
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
