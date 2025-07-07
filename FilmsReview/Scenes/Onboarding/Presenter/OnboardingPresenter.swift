//
//  OnboardingPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import UIKit

protocol OnboardingPresenterProtocol: PresenterProtocol {
    func presentSlideChanged(index: Int, isLast: Bool)
    func presentFinish() 
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
    func presentSlideChanged(index: Int, isLast: Bool) {
        (viewController as? OnboardingViewControllerProtocol)?.updatePageControl(currentPage: index)
        (viewController as? OnboardingViewControllerProtocol)?.toggleSkipButton(hidden: isLast)
    }
    
    func presentFinish() {
        (viewController as? OnboardingViewControllerProtocol)?.navigateToMainApp()
    }
}
