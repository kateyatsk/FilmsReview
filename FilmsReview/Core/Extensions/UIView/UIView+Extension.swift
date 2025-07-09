//
//  UIView+Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.07.25.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach({addSubview($0)})
    }
}
