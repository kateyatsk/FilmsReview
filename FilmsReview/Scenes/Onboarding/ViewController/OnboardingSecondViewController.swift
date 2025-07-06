//
//  OnboardingSecondViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import UIKit

final class OnboardingSecondViewController: BaseOnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContent(imageName: "onboarding_rate_share",
                         title: "Rate & Share",
                         description: "Your opinion matters — help others pick the right movie by sharing your ratings and reviews",
                         pageIndex: 1,
                         isLastPage: false)
    }

    override func nextTapped() {
        guard let output = (interactor as? OnboardingInteractor)?.handleNext(step: .second) else { return }
        if output == .goToThird {
            (router as? OnboardingRouter)?.routeToThird()
        }
    }

    override func skipTapped() {
        guard let output = (interactor as? OnboardingInteractor)?.handleSkip() else { return }
        if output == .finish {
            (router as? OnboardingRouter)?.finishOnboarding()
        }
    }
}
