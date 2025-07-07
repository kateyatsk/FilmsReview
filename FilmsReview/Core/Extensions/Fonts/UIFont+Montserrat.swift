//
//  UIFont+Montserrat.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.07.25.
//

import UIKit

extension UIFont {
    static func montserrat(_ weight: MontserratWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size)!
    }
}

enum MontserratWeight: String {
    case regular = "Montserrat-Regular"
    case medium = "Montserrat-Medium"
    case semiBold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"
    case extraBold = "Montserrat-ExtraBold"
}
