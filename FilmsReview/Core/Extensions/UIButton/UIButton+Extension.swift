//
//  UIButton+Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 11.07.25.
//

import Foundation
import UIKit

enum ButtonStyle {
    case filled
    case outlined
}

extension UIButton {
    static func styled(
        title: String,
        style: ButtonStyle,
        target: Any?,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .montserrat(.medium, size: FontSize.body)
        button.layer.cornerRadius = CornerRadius.xl
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: Size.xl2.height).isActive = true

        switch style {
        case .filled:
            button.backgroundColor = .buttonPrimary
            button.setTitleColor(.white, for: .normal)
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 6)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
        case .outlined:
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.buttonPrimary.cgColor
            button.setTitleColor(.buttonPrimary, for: .normal)
        }

        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}
