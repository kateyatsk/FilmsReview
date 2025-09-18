//
//  MovieCardCell.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Layout {
        static let gapPosterToTitle: CGFloat = 12
        static let gapTitleToGenres: CGFloat = 6
    }
    
    enum Text {
        static let numberOfLines: Int = 1
        static let font: UIFont = .montserrat(.regular, size: 14)
    }
}

final class MovieCardCell: UICollectionViewCell {
    static let reuseId = "MovieCardCell"

    private lazy var posterView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = CornerRadius.xl
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.semiBold, size: FontSize.body)
        label.textColor = .titlePrimary
        label.numberOfLines = Constants.Text.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var genresLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Text.font
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.Text.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.image = nil
        titleLabel.text = nil
        genresLabel.text = nil
    }

    private func setupConstraints() {
        contentView.addSubviews(posterView, titleLabel, genresLabel)

        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterView.heightAnchor.constraint(equalTo: posterView.widthAnchor, multiplier: PosterAspect.h4x3.hOverW),

            titleLabel.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: Constants.Layout.gapPosterToTitle),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),

            genresLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Layout.gapTitleToGenres),
            genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genresLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            genresLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func configure(title: String, genres: String, poster: UIImage?) {
        titleLabel.text = title
        genresLabel.text = genres
        posterView.image = poster
    }
}
