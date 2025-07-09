//
//  OnboardingInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation

protocol OnboardingInteractorProtocol: InteractorProtocol {
    func didScrollToSlide(at index: Int)
    func skipTapped()
}

final class OnboardingInteractor: OnboardingInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    var worker: OnboardingWorker
    
    init(presenter: OnboardingPresenter? = nil, worker: OnboardingWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func didScrollToSlide(at index: Int) {
        let isLast = index == Onboarding.slides.count - 1
        (presenter as? OnboardingPresenterProtocol)?.presentSlideChanged(index: index, isLast: isLast)
    }

    func skipTapped() {
        worker.markOnboardingAsPassed()
        (presenter as? OnboardingPresenterProtocol)?.presentFinish()
    }
    
}
