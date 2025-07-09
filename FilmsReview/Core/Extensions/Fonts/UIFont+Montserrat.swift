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
    static let caption: CGFloat = 12
    static let body: CGFloat = 16
    static let subtitle: CGFloat = 18
    static let title: CGFloat = 24
    static let largeTitle: CGFloat = 32
}
