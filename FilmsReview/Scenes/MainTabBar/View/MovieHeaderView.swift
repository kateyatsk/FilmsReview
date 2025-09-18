//
//  MovieHeaderView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Text {
        static let play = "Play"
    }
    
    enum Layout {
        static let chipSpacing: CGFloat = 6
        
        static let unlimitedNumberOfLines: Int = 0
        static let overlayAlpha: CGFloat = 0.4
        
        static let verticalInset: CGFloat = 14
        static let size: CGFloat = 18
        static let horizontalInset: CGFloat = 20
        static let buttonSize: CGFloat = 48
    }
    
    enum Shadow {
        static let opacity: Float = 0.12
    }
    
    enum Symbols {
        static let back = "arrow.backward"
        static let playFill = "play.fill"
        static let heart = "heart"
        static let heartFill = "heart.fill"
    }
}

final class MovieHeaderView: UIView {
    var onBack: (() -> Void)?
    var onPlay: (() -> Void)?
    var onLike: ((_ isLiked: Bool) -> Void)?
    
    private lazy var posterView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(Constants.Layout.overlayAlpha)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: FontSize.title, weight: .regular)
        button.setImage(UIImage(systemName: Constants.Symbols.back, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onBackTap), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.bold, size: Size.s.width)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.Text.play, for: .normal)
        button.setImage(UIImage(systemName: Constants.Symbols.playFill), for: .normal)
        
        button.tintColor = .white
        button.backgroundColor = .buttonPrimary
        button.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        button.layer.cornerRadius = CornerRadius.xl2
        
        button.contentEdgeInsets = .init(
            top: Constants.Layout.verticalInset,
            left: Spacing.xs2,
            bottom: Constants.Layout.verticalInset,
            right: Spacing.xs2
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets( top: .zero, left: Spacing.xs4, bottom: .zero, right: -Spacing.xs4 )
        button.imageEdgeInsets = UIEdgeInsets( top: .zero, left: -Spacing.xs5, bottom: .zero, right: Spacing.xs5 )
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        makeCircleButton(symbol: Constants.Symbols.heart, tintColor: .buttonPrimary, backgroundColor: .white)
    }()
    
    private lazy var headerButtons: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, likeButton])
        stack.axis = .horizontal
        stack.spacing = Size.xs2.width
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var metaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Size.xs2.width
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var isLiked = false {
        didSet { updateLikeAppearance() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        build()
    }
    required init?(coder: NSCoder) { nil }
    
    private func build() {
        addSubviews(
            posterView,
            overlayView,
            backButton,
            titleLabel,
            overviewLabel,
            metaStack,
            headerButtons
        )
        
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: topAnchor),
            posterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            posterView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: posterView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: posterView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: posterView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: posterView.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Size.xs2.width),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Size.m.width),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.xs3),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.xs3),
            titleLabel.bottomAnchor.constraint(equalTo: overviewLabel.topAnchor, constant: -Spacing.xs5),
            
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.bottomAnchor.constraint(equalTo: metaStack.topAnchor, constant: -Spacing.xs4),
            
            metaStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            metaStack.bottomAnchor.constraint(equalTo: headerButtons.topAnchor, constant: -Spacing.xs3),
            
            headerButtons.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerButtons.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.xs3),
        ])
        
        likeButton.addTarget(self, action: #selector(onLikeTap), for: .touchUpInside)
    }
    
    func configure(poster: UIImage?, title: String, overview: String, metaChips: [MetaChip]) {
        posterView.image = poster
        titleLabel.text = title
        let firstSentence: String
        if let dotRange = overview.firstIndex(of: ".") {
            let substring = overview[..<dotRange]
            firstSentence = substring.trimmingCharacters(in: .whitespacesAndNewlines) + "."
        } else {
            firstSentence = overview
        }
        overviewLabel.text = firstSentence
        
        metaStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metaChips.forEach { chip in
            metaStack.addArrangedSubview(makeChip(text: chip.text, image: chip.icon))
        }
    }
    
    @objc private func onBackTap() { onBack?() }
    @objc private func onPlayTap() { onPlay?() }
    @objc private func onLikeTap() {
        isLiked.toggle()
        onLike?(isLiked)
    }
    
    private func updateLikeAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: FontSize.subtitle, weight: .semibold)
        let name = isLiked ? Constants.Symbols.heartFill : Constants.Symbols.heart
        likeButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
    
    private func makeChip(text: String, image: UIImage? = nil) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.Layout.chipSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        if let image {
            let view = UIImageView(image: image)
            view.contentMode = .scaleAspectFit
            view.tintColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: Constants.Layout.size),
                view.heightAnchor.constraint(equalToConstant: Constants.Layout.size)
            ])
            stack.addArrangedSubview(view)
        }
        
        let label = UILabel()
        label.text = text
        label.font = .montserrat(.regular, size: Size.xs3.height)
        label.textColor = .white
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    private func makeCircleButton(symbol: String, tintColor: UIColor, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: FontSize.subtitle, weight: .semibold)
        
        button.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = backgroundColor
        
        let size = Constants.Layout.buttonSize
        button.layer.cornerRadius = size / 2
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
            
        ])
        
        return button
    }
}
