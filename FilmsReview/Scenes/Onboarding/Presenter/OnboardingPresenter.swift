//
//  OnboardingPresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.07.25.
//

import Foundation
import UIKit

protocol OnboardingPresenterProtocol: PresenterProtocol {
 
}

final class OnboardingPresenter: OnboardingPresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    init(viewController: ViewControllerProtocol? = nil) {
        self.viewController = viewController
    }
    
}
