//
//  OnboardingSlideCell.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 7.07.25.
//

import UIKit

final class OnboardingSlideCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    private var actionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        [imageView, titleLabel, descriptionLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
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
                
                actionButton.topAnchor.constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: OnboardingConstants.SlideCell.buttonTopPadding
                )
                
            ]
        )
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configure(imageName: String, title: String, description: String, isLast: Bool, action: @escaping () -> Void) {
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        titleLabel.font = .montserrat(.extraBold, size: OnboardingConstants.SlideCell.titleFontSize)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .titlePrimary
        descriptionLabel.text = description
        descriptionLabel.font = .montserrat(.regular, size: OnboardingConstants.SlideCell.descriptionFontSize)
        descriptionLabel.textColor = .bodyText
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        
        actionHandler = action
        
        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = isLast ? OnboardingConstants.SlideCell.startButtonCornerRadius : OnboardingConstants.SlideCell.nextButtonCornerRadius
        actionButton.backgroundColor = isLast ? .buttonPrimary : .titlePrimary
        
        if isLast {
            actionButton.setTitle(OnboardingConstants.SlideCell.startButtonTitle, for: .normal)
            actionButton.titleLabel?.font = .montserrat(.medium, size: OnboardingConstants.SlideCell.startButtonFontSize)
            actionButton.widthAnchor.constraint(equalToConstant:  OnboardingConstants.SlideCell.startButtonWidth).isActive = true
            actionButton.heightAnchor.constraint(equalToConstant:  OnboardingConstants.SlideCell.startButtonHeight).isActive = true
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        } else {
            let arrowImage = UIImage(systemName: "arrow.right")
            actionButton.setImage(arrowImage, for: .normal)
            actionButton.titleLabel?.font = .montserrat(.regular, size:  OnboardingConstants.SlideCell.nextButtonFontSize)
            actionButton.widthAnchor.constraint(equalToConstant: OnboardingConstants.SlideCell.nextButtonSize).isActive = true
            actionButton.heightAnchor.constraint(equalToConstant:  OnboardingConstants.SlideCell.nextButtonSize).isActive = true
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        }
    }
    
    @objc private func buttonTapped() {
        actionHandler?()
    }
}
