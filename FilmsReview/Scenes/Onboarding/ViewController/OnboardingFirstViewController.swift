//
//  OnboardingFirstViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import UIKit

final class OnboardingFirstViewController: BaseOnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContent(imageName: "onboarding_welcome",
                         title: "Welcome to FilmsReview",
                         description: "Discuss movies, share your thoughts, and discover what’s worth watching.",
                         pageIndex: 0,
                         isLastPage: false)
        
    }

    override func nextTapped() {
        guard let output = (interactor as? OnboardingInteractor)?.handleNext(step: .first) else { return }
        if output == .goToSecond {
            (router as? OnboardingRouter)?.routeToSecond()
        }
    }

    override func skipTapped() {
        guard let output = (interactor as? OnboardingInteractor)?.handleSkip() else { return }
        if output == .finish {
            (router as? OnboardingRouter)?.finishOnboarding()
        }
    }
}

