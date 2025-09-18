//
//  TabBarViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//


import UIKit

protocol TabBarVC: ViewControllerProtocol {}

final class TabBarViewController: UITabBarController, TabBarVC {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureAppearance() {
        view.backgroundColor = .white

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        tabBar.tintColor = .titlePrimary
        tabBar.unselectedItemTintColor = .secondaryLabel

        tabBar.standardAppearance = appearance
    }
    
}
