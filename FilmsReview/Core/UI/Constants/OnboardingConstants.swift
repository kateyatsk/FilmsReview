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
        static let imageTopPadding: CGFloat = Spacing.xxLarge
        static let titleTopPadding: CGFloat = Spacing.large
        static let sidePadding: CGFloat = Spacing.large
        static let descriptionTopPadding: CGFloat = Spacing.medium
        static let buttonTopPadding: CGFloat = Spacing.xxLarge
        
        static let titleFontSize: CGFloat = FontSize.title
        static let descriptionFontSize: CGFloat = FontSize.body
        static let startButtonFontSize: CGFloat = FontSize.body
        static let nextButtonFontSize: CGFloat = FontSize.largeTitle
        
        static let nextButtonSize: CGFloat = ButtonSize.icon
        static let nextButtonCornerRadius: CGFloat = CornerRadius.circle
        
        static let startButtonWidth: CGFloat = ButtonSize.large.width
        static let startButtonHeight: CGFloat = ButtonSize.large.height
        static let startButtonCornerRadius: CGFloat = CornerRadius.medium
        
        static let startButtonTitle = "Get Started"
    }
    
    enum ViewController {
        static let skipButtonTop: CGFloat = Spacing.medium
        static let skipButtonTrailing: CGFloat = Spacing.large
        static let pageControlBottom: CGFloat = Spacing.large
        
        static let skipButtonTitle = "Skip"
        static let skipButtonFontSize: CGFloat = FontSize.body
    }
}
