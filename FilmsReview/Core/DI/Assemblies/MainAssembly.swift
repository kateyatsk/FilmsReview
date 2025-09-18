//
//  
//  HomeAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//

import Swinject
import UIKit

final class MainAssembly: Assembly {
    func assemble(container: Container) {

        container.register(MainTabBarWorker.self) { _ in
            MainTabBarWorker()
        }
        .inObjectScope(.container)

        container.register(MainTabBarPresenter.self) { _ in
            MainTabBarPresenter()
        }
        .inObjectScope(.graph)

        container.register(MainTabBarRouter.self) { _ in
            MainTabBarRouter()
        }
        .inObjectScope(.container)

        container.register(MainTabBarInteractor.self) { r in
            guard
                let presenter = r.resolve(MainTabBarPresenter.self),
                let worker = r.resolve(MainTabBarWorker.self)
            else {
                fatalError("DI: HomeInteractor deps missing")
                return MainTabBarInteractor(presenter: MainTabBarPresenter(), worker: MainTabBarWorker())
            }
            return MainTabBarInteractor(presenter: presenter, worker: worker)
        }
        .inObjectScope(.graph)

        container.register(TabBarViewController.self) { r in
            let tab = TabBarViewController()

            guard
                let homeVC = r.resolve(HomeViewController.self),
                let searchVC = r.resolve(SearchViewController.self),
                let favoriteVC = r.resolve(FavoriteViewController.self),
                let profileVC = r.resolve(ProfileViewController.self)
            else {
                fatalError("DI: TabBar tabs resolve failed")
            }

            let home = UINavigationController(rootViewController: homeVC)
            home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)

            let search = UINavigationController(rootViewController: searchVC)
            search.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)

            let favorite = UINavigationController(rootViewController: favoriteVC)
            favorite.tabBarItem = UITabBarItem(title: "Favorite", image: UIImage(systemName: "heart"), selectedImage: nil)

            let profile = UINavigationController(rootViewController: profileVC)
            profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: nil)

            tab.setViewControllers([home, search, favorite, profile], animated: false)
            tab.selectedIndex = 0
            return tab
        }
        .inObjectScope(.container)


        container.register(MovieDetailsViewController.self) { r in
            let vc = MovieDetailsViewController()

            if let mainRouter = r.resolve(MainTabBarRouter.self) {
                vc.router = mainRouter
            } else {
                fatalError("DI: MovieDetailsViewController router resolve failed")
            }

            return vc
        }
        .inObjectScope(.transient)
    }
}
