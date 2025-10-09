//
//  HomeHeaderView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//

import UIKit

fileprivate enum Constants {
    static let avatarSide: CGFloat = 48
    static let textStackSpacing: CGFloat = 2
    
    static let notificationSystemImageName = "bell"

    static let badgeTrailingOffset: CGFloat = -2
    static let badgeCornerRadius: CGFloat = 5
    
    static let subtitleDefaultText = "Let's watch a movie"
    static let greetingFormat = "Hi, %@"
    static let greetingFallback = "Hi there"
}

final class HomeHeaderView: UIView {
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.xl2
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.bold, size: FontSize.subtitle)
        label.textColor = .titlePrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.regular, size: FontSize.body)
        label.textColor = .secondaryLabel
        label.text = Constants.subtitleDefaultText
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: Constants.notificationSystemImageName), for: .normal)
        button.tintColor = .titlePrimary
        return button
    }()
    
    private lazy var badgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .buttonPrimary
        view.layer.cornerRadius = Constants.badgeCornerRadius
        view.isHidden = false
        return view
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Constants.textStackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(avatar: UIImage?, name: String) {
        avatarImageView.image = avatar
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        titleLabel.text = trimmed.isEmpty ? Constants.greetingFallback : String(format: Constants.greetingFormat, trimmed)
    }
    
    private func setupLayout() {
        addSubviews(avatarImageView, textStack, notificationButton)
        notificationButton.addSubview(badgeView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSide),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSide),
            
            textStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor,
                                               constant: Size.xs2.width),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            notificationButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            badgeView.topAnchor.constraint(equalTo: notificationButton.topAnchor,
                                           constant: Spacing.xs5),
            badgeView.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor,
                                                constant: Constants.badgeTrailingOffset),
            badgeView.widthAnchor.constraint(equalToConstant: Size.xs3.width),
            badgeView.heightAnchor.constraint(equalToConstant: Size.xs3.height),
        ])
    }
}
