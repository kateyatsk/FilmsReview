//
//  SceneDelegate.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 23.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        AppRouter.startApp(window: window)
        self.window = window
    }
    
}

