//
//  OnboardingConstants.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.07.25.
//

import Foundation

enum OnboardingConstants {
    
    enum SlideCell {
        static let imageSize: CGFloat = 300
        static let imageTopPadding: CGFloat = 60
        static let titleTopPadding: CGFloat = 30
        static let sidePadding: CGFloat = 24
        static let descriptionTopPadding: CGFloat = 16
        static let buttonTopPadding: CGFloat = 60
        
        static let titleFontSize: CGFloat = 24
        static let descriptionFontSize: CGFloat = 16
        static let startButtonFontSize: CGFloat = 16
        static let nextButtonFontSize: CGFloat = 38
        
        static let nextButtonSize: CGFloat = 60
        static let nextButtonCornerRadius: CGFloat = 30
        
        static let startButtonWidth: CGFloat = 160
        static let startButtonHeight: CGFloat = 40
        static let startButtonCornerRadius: CGFloat = 20
        
        static let startButtonTitle = "Get Started"
    }
    
    enum ViewController {
        static let skipButtonTop: CGFloat = 20
        static let skipButtonTrailing: CGFloat = 24
        static let pageControlBottom: CGFloat = 30
        
        static let skipButtonTitle = "Skip"
        
        static let skipButtonFontSize: CGFloat = 16
    }
}
