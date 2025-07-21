//
//  UITextField+Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 11.07.25.
//

import UIKit

extension UITextField {
    func setPlaceholder(_ text: String, color: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color]
        )
    }
}
