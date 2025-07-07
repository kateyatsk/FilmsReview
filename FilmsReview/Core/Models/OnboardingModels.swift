//
//  OnboardingModels.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation

enum Onboarding {
    struct Slide {
        let image: String
        let title: String
        let description: String
    }
    
    static let slides: [Slide] = [
        Slide(image: "onboarding_welcome",
              title: "Welcome to FilmsReview",
              description: "Discuss movies, share your thoughts, and discover what’s worth watching."),
        
        Slide(image: "onboarding_rate_share",
              title: "Rate & Share",
              description: "Your opinion matters — help others pick the right movie by sharing your ratings and reviews."),
        
        Slide(image: "onboarding_recommendations",
              title: "Find Movies You’ll Love",
              description: "Get personalized recommendations and curated lists based on what you like.")
    ]
}
