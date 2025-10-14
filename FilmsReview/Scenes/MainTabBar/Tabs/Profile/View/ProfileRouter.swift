//
//  
//  ProfileRouter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit
import FirebaseAuth

protocol ProfileRouterProtocol: RouterProtocol {
    func routeToAuth()
}

final class ProfileRouter: ProfileRouterProtocol {
    weak var viewController: (any ViewControllerProtocol)?

    func routeToAuth() {
        try? Auth.auth().signOut()
        AppSettings.isAuthorized = false
        AppRouter.updateRootViewController()
    }
}
