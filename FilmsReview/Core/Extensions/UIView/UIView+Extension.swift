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

extension UIView {
    func nearestViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController { return vc }
            responder = next
        }
        return nil
    }
}
