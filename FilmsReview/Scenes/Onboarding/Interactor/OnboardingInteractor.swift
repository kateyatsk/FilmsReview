//
//  OnboardingInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation

protocol OnboardingInteractorProtocol: InteractorProtocol {
    func handleNext(step: OnboardingStep) -> OnboardingOutput
    func handleSkip() -> OnboardingOutput
}

enum OnboardingStep {
    case first
    case second
    case third
}

enum OnboardingOutput {
    case goToSecond
    case goToThird
    case finish
}

final class OnboardingInteractor: OnboardingInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: OnboardingWorker
    
    init(presenter: OnboardingPresenter? = nil, worker: OnboardingWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func handleNext(step: OnboardingStep) -> OnboardingOutput {
        switch step {
        case .first:
                .goToSecond
        case .second:
                .goToThird
        case .third:
                .finish
        }
    }
    
    func handleSkip() -> OnboardingOutput {
        .finish
    }
    
}
