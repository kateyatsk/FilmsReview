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
        
        let env = ProcessInfo.processInfo.environment
        
        UITestLauncher.applyToggles(from: env)
        
        if let root = UITestLauncher.desiredRoot(from: env) {
            setRoot(root, in: windowScene)
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        AppRouter.startApp(window: window)
        self.window = window
    }
    
    
    private func setRoot(_ root: UIViewController, in scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.rootViewController = root
        self.window = window
        window.makeKeyAndVisible()
    }
}

