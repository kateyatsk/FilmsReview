//
//  OnboardingThirdViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import UIKit

final class OnboardingThirdViewController: BaseOnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContent(imageName: "onboarding_recommendations",
                         title: "Find Movies You’ll Love",
                         description: "Get personalized recommendations and curated lists based on what you like",
                         pageIndex: 2,
                         isLastPage: true)
    }

    override func nextTapped() {
        guard let output = (interactor as? OnboardingInteractor)?.handleNext(step: .third) else { return }
        if output == .finish {
            (router as? OnboardingRouter)?.finishOnboarding()
        }
    }

    override func skipTapped() {
        nextTapped()
    }
}
