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
        $0.font = .montserrat(.extraBold, size: OnboardingConstants.SlideCell.titleFontSize)
        $0.textAlignment = .left
        $0.textColor = .titlePrimary
        return $0
    }(UILabel())
    
    private lazy var descriptionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .montserrat(.regular, size: OnboardingConstants.SlideCell.descriptionFontSize)
        $0.textColor = .bodyText
        $0.textAlignment = .left
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private lazy var nextButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        $0.backgroundColor = .titlePrimary
        $0.layer.cornerRadius = OnboardingConstants.SlideCell.nextButtonCornerRadius
        $0.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var startButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        $0.backgroundColor = .buttonPrimary
        $0.layer.cornerRadius = OnboardingConstants.SlideCell.startButtonCornerRadius
        $0.setTitle(OnboardingConstants.SlideCell.startButtonTitle, for: .normal)
        $0.titleLabel?.font = .montserrat(.medium, size: OnboardingConstants.SlideCell.startButtonFontSize)
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
                    constant: OnboardingConstants.SlideCell.imageTopPadding
                ),
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.heightAnchor.constraint(equalToConstant: OnboardingConstants.SlideCell.imageSize),
                imageView.widthAnchor.constraint(equalToConstant: OnboardingConstants.SlideCell.imageSize),
                
                titleLabel.topAnchor.constraint(
                    equalTo: imageView.bottomAnchor,
                    constant: OnboardingConstants.SlideCell.titleTopPadding
                ),
                titleLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: OnboardingConstants.SlideCell.sidePadding
                ),
                titleLabel.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -OnboardingConstants.SlideCell.sidePadding
                ),
                
                descriptionLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: OnboardingConstants.SlideCell.descriptionTopPadding
                ),
                descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                nextButton.topAnchor.constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: OnboardingConstants.SlideCell.buttonTopPadding
                ),
                nextButton.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Spacing.large
                ),
                nextButton.widthAnchor.constraint(
                    equalToConstant: OnboardingConstants.SlideCell.nextButtonSize
                ),
                nextButton.heightAnchor.constraint(
                    equalToConstant: OnboardingConstants.SlideCell.nextButtonSize
                ),
                
                startButton.widthAnchor.constraint(
                    equalToConstant: OnboardingConstants.SlideCell.startButtonWidth
                ),
                startButton.heightAnchor.constraint(
                    equalToConstant: OnboardingConstants.SlideCell.startButtonHeight
                ),
                startButton.topAnchor.constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: OnboardingConstants.SlideCell.buttonTopPadding
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
