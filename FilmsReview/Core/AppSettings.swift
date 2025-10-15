//
//  AppSettings.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation

final class AppSettings {
    static var isOnboardingShown: Bool {
        get { UserDefaults.standard.bool(forKey: "isOnboardingShown") }
        set { UserDefaults.standard.set(newValue, forKey: "isOnboardingShown") }
    }

    static var isAuthorized: Bool {
        get { UserDefaults.standard.bool(forKey: "isAuthorized") }
        set { UserDefaults.standard.set(newValue, forKey: "isAuthorized") }
    }
}
