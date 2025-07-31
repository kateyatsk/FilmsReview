//
//  ValidationTagCell.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 23.07.25.
//

import UIKit

fileprivate enum Constants {
    enum FontSize {
        static let small: CGFloat = 11
    }
    
    enum Spacing {
        static let tagHeight: CGFloat = 3
    }
}

final class ValidationTagCell: UICollectionViewCell {
    static let reuseID = "ValidationTagCell"
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Size.xs2.width),
            imageView.heightAnchor.constraint(equalToConstant: Size.xs2.height)
        ])
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.medium, size: Constants.FontSize.small)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = CornerRadius.xs
        contentView.layer.borderWidth = Spacing.xs6
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.layer.masksToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.spacing = Spacing.xs5
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Spacing.tagHeight),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Spacing.tagHeight),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.xs5),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.xs5)
        ])
    }
    
    func configure(message: String, isValid: Bool) {
        label.text = message
        let color: UIColor = isValid ? .systemGreen : .systemGray
        label.textColor = color
        iconView.image = UIImage(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
        iconView.tintColor = color
        contentView.layer.borderColor = color.cgColor
    }
}


