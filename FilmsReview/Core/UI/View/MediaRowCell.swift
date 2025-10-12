//
//  MediaRowCell.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Poster {
        static let widthMultiplier: CGFloat = 1.0 / 3.0
    }
    enum Text {
        static let numberOfLines: Int = 1
        static let subtitleFont: UIFont = .montserrat(.regular, size: 14)
        static let leadingSpacing: CGFloat = 12
        static let trailingSpacing: CGFloat = 12
    }
    enum PlayButton {
        static let systemName = "play.circle"
        static let contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

final class MediaRowCell: UICollectionViewCell {
    static let reuseId = "MediaRowCell"
    var onPlay: (() -> Void)?
    
    private lazy var posterView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = CornerRadius.m
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.semiBold, size: FontSize.subtitle)
        label.textColor = .titlePrimary
        label.numberOfLines = Constants.Text.numberOfLines
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Text.subtitleFont
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.Text.numberOfLines
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: Constants.PlayButton.systemName), for: .normal)
        button.tintColor = .titlePrimary
        button.contentEdgeInsets = Constants.PlayButton.contentInsets
        return button
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Spacing.xs5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        
        contentView.addSubviews(posterView, playButton, textStack)
        
        NSLayoutConstraint.activate([
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Constants.Poster.widthMultiplier),
            posterView.heightAnchor.constraint(equalTo: posterView.widthAnchor, multiplier: PosterAspect.h9x16.hOverW),
            
            playButton.centerYAnchor.constraint(equalTo: posterView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            textStack.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: Constants.Text.leadingSpacing),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -Constants.Text.trailingSpacing),
            textStack.centerYAnchor.constraint(equalTo: posterView.centerYAnchor)
        ])
        
        playButton.addTarget(self, action: #selector(onTapPlay), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with item: MediaItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        posterView.image = item.backdrop ?? item.poster
    }
    
    @objc private func onTapPlay() { onPlay?() }
}
