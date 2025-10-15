//
//  OnboardingSlideCell.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.07.25.
//

import UIKit

final class OnboardingSlideCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.textAlignment = .left
        $0.textColor = .titlePrimary
        return $0
    }(UILabel())
    
    private lazy var descriptionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .montserrat(.regular, size: FontSize.body)
        $0.textColor = .bodyText
        $0.textAlignment = .left
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private lazy var nextButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        $0.backgroundColor = .titlePrimary
        $0.layer.cornerRadius = CornerRadius.xl3
        $0.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var startButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        $0.backgroundColor = .buttonPrimary
        $0.layer.cornerRadius = CornerRadius.xl
        $0.setTitle("Get Started", for: .normal)
        $0.titleLabel?.font = .montserrat(.medium, size: FontSize.body)
        $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private var actionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(
            imageView,
            titleLabel,
            descriptionLabel,
            nextButton,
            startButton
        )
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        
        NSLayoutConstraint.activate(
            [
                imageView.topAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                    constant:  Spacing.xl5                ),
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.heightAnchor.constraint(equalToConstant:  Size.xl6.width),
                imageView.widthAnchor.constraint(equalToConstant: Size.xl6.height),
                
                titleLabel.topAnchor.constraint(
                    equalTo: imageView.bottomAnchor,
                    constant: Spacing.xs
                ),
                titleLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: Spacing.xs
                ),
                titleLabel.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Spacing.xs
                ),
                
                descriptionLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Spacing.xs3
                ),
                descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                nextButton.topAnchor.constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: Spacing.xl5
                ),
                nextButton.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Spacing.xs
                ),
                nextButton.widthAnchor.constraint(
                    equalToConstant: Size.xl3.width
                ),
                nextButton.heightAnchor.constraint(
                    equalToConstant: Size.xl3.height
                ),
                
                startButton.widthAnchor.constraint(
                    equalToConstant: Size.xl5.width
                ),
                startButton.heightAnchor.constraint(
                    equalToConstant: Size.xl.height
                ),
                startButton.topAnchor.constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: Spacing.xl5
                ),
                startButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
                
            ]
        )
        
    }
    
    func configure(imageName: String, title: String, description: String, isLast: Bool, action: @escaping () -> Void) {
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        descriptionLabel.text = description
        
        actionHandler = action
        
        nextButton.isHidden = isLast
        startButton.isHidden = !isLast
        
    }
    
    @objc private func buttonTapped() {
        actionHandler?()
    }
}
