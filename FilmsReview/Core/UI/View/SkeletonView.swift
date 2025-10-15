//
//  SkeletonView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.10.25.
//

import UIKit

fileprivate enum Constants {
    enum Colors {
        static let base = UIColor.systemGray5.cgColor
        static let highlight = UIColor.systemGray4.withAlphaComponent(0.7).cgColor
    }
    
    enum Animation {
        static let keyPath = "locations"
        static let key = "shimmer"
        static let fromValue: [NSNumber] = [-1.0, -0.5, 0.0]
        static let toValue: [NSNumber] = [1.0, 1.5, 2.0]
        static let duration: CFTimeInterval = 1.4
        static let repeatCount: Float = .infinity
    }
    
    enum Gradient {
        static let startPoint = CGPoint(x: 0, y: 0.5)
        static let endPoint = CGPoint(x: 1, y: 0.5)
        static let locations: [NSNumber] = [0, 0.5, 1]
    }
}

final class SkeletonView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private var shimmerAnimation: CABasicAnimation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        backgroundColor = .clear
        layer.masksToBounds = true
        
        gradientLayer.colors = [
            Constants.Colors.base,
            Constants.Colors.highlight,
            Constants.Colors.base
        ]
        gradientLayer.startPoint = Constants.Gradient.startPoint
        gradientLayer.endPoint = Constants.Gradient.endPoint
        gradientLayer.locations = Constants.Gradient.locations
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startShimmer() {
        let animation = CABasicAnimation(keyPath: Constants.Animation.keyPath)
        animation.fromValue = Constants.Animation.fromValue
        animation.toValue = Constants.Animation.toValue
        animation.duration = Constants.Animation.duration
        animation.repeatCount = Constants.Animation.repeatCount
        gradientLayer.add(animation, forKey: Constants.Animation.key)
        shimmerAnimation = animation
    }

    func stopShimmer() {
        gradientLayer.removeAnimation(forKey: Constants.Animation.key)
    }
}
