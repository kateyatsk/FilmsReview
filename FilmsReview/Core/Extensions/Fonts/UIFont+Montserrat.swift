//
//  UIFont+Montserrat.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.07.25.
//

import UIKit

extension UIFont {
    static func montserrat(_ weight: MontserratWeight, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}

enum MontserratWeight: String {
    case regular = "Montserrat-Regular"
    case medium = "Montserrat-Medium"
    case semiBold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"
    case extraBold = "Montserrat-ExtraBold"
}

enum FontSize {
    /// Caption text (12pt)
    public static let caption: CGFloat = 12
    
    /// Body text (16pt)
    public static let body: CGFloat = 16
    
    /// Subtitle text (18pt)
    public static let subtitle: CGFloat = 18
    
    /// Title text (24pt)
    public static let title: CGFloat = 24
    
    /// Large title text (32pt)
    public static let largeTitle: CGFloat = 32
}
