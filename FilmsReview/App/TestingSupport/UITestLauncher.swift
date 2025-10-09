//
//  UITestLauncher.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 1.09.25.
//

import UIKit

enum UITestLauncher {
    static let toggles: [String: () -> Void] = [
        "UITesting_ResetOnboarding": { AppSettings.isOnboardingShown = false },
        "UITesting_SkipOnboarding":  { AppSettings.isOnboardingShown = true  }
    ]
    
    static let roots: [String: () -> UIViewController] = [
        "UITesting_ChooseInterests": {
            let vc = ChooseInterestsViewController()
            vc.loadViewIfNeeded()
            vc.displayGenres(["Action","Comedy","Drama","Fantasy","Horror","Mystery","Romance","Thriller"])
            return UINavigationController(rootViewController: vc)
        },
        "UITesting_CreateProfileScreen": {
            CreateProfileViewController()
        }
    ]
    
    static func applyToggles(from env: [String: String]) {
        for key in toggles.keys where env[key] == "1" {
            toggles[key]?()
        }
    }
    
    static func desiredRoot(from env: [String: String]) -> UIViewController? {
        let activeRoots = env.filter { $0.value == "1" && roots[$0.key] != nil }
        guard activeRoots.count <= 1 else {
            fatalError("Несколько root-флагов активированы: \(activeRoots.keys)")
        }
        if let (key, _) = activeRoots.first {
            return roots[key]?()
        }
        return nil
    }
}

