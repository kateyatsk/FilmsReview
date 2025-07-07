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
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 60)

        ])
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func configure(imageName: String, title: String, description: String, isLast: Bool, action: @escaping () -> Void) {
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        titleLabel.font = .montserrat(.extraBold, size: 24)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .titlePrimary
        descriptionLabel.text = description
        descriptionLabel.font = .montserrat(.regular, size: 16)
        descriptionLabel.textColor = .bodyText
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        
        actionHandler = action
        
        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = isLast ? 20 : 30
        actionButton.backgroundColor = isLast ? .buttonPrimary : .titlePrimary
        
        if isLast {
            actionButton.setTitle("Get Started", for: .normal)
            actionButton.titleLabel?.font = .montserrat(.medium, size: 16)
            actionButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
            actionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        } else {
            actionButton.setTitle("→", for: .normal)
            actionButton.titleLabel?.font = .montserrat(.regular, size: 38)
            actionButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            actionButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        }
    }
    
    @objc private func buttonTapped() {
        actionHandler?()
    }
}
