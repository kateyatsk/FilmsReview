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
        
        if ProcessInfo.processInfo.environment["UITesting_ResetOnboarding"] == "1" {
            AppSettings.isOnboardingShown = false
        }
        
        if ProcessInfo.processInfo.environment["UITesting_SkipOnboarding"] == "1" {
            AppSettings.isOnboardingShown = true
        }
        
        if ProcessInfo.processInfo.environment["UITesting_CreateProfileScreen"] == "1" {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = CreateProfileViewController()
            self.window = window
            window.makeKeyAndVisible()
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        AppRouter.startApp(window: window)
        self.window = window
    }
    
}

