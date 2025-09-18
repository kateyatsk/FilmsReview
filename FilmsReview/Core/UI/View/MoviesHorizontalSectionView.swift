//
//  MoviesHorizontalSectionView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Layout {
        static let cellSpacing: CGFloat = 16
        static let gapTitleToCollection: CGFloat = 12
        static let gapPosterToTitle: CGFloat = 12
        static let gapTitleToGenres: CGFloat = 6
        static let labelsBottomPadding: CGFloat = 16
        static let defaultRowHeight: CGFloat = 240
        static let minItemWidth: CGFloat = 1
    }
    
    enum Text {
        static let seeAll = "See All"
        static let genresFontSize: CGFloat = 14
    }
}

protocol MoviesSectionViewDelegate: AnyObject {
    func moviesSectionDidTapSeeAll(_ view: MoviesHorizontalSectionView)
    func moviesSection(_ view: MoviesHorizontalSectionView, didSelect index: Int)
}

final class MoviesHorizontalSectionView: UIView,
                                         UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let title: String
    private let titleFontSize: CGFloat
    private let seeAllTitle: String
    private let posterAspectHW: CGFloat
    private let showsSeeAll: Bool
    private let rowHeight: CGFloat
    
    weak var delegate: MoviesSectionViewDelegate?
    
    var items: [MediaItem] = [] { didSet { collectionView.reloadData() } }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.bold, size: titleFontSize)
        label.textColor = .titlePrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.buttonPrimary, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: titleFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onSeeAll), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.Layout.cellSpacing
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCardCell.self, forCellWithReuseIdentifier: MovieCardCell.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var collectionHeight: NSLayoutConstraint?
    
    init(
        title: String,
        fontSize: CGFloat = FontSize.body,
        seeAllTitle: String = Constants.Text.seeAll,
        posterAspectHW: CGFloat = PosterAspect.h4x3.hOverW,
        showsSeeAll: Bool = true,
        rowHeight: CGFloat = Constants.Layout.defaultRowHeight
    ) {
        self.title = title
        self.titleFontSize = fontSize
        self.seeAllTitle = seeAllTitle
        self.posterAspectHW = posterAspectHW
        self.showsSeeAll = showsSeeAll
        self.rowHeight = rowHeight
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        addSubviews(titleLabel, seeAllButton, collectionView)
        
        titleLabel.text = title
        seeAllButton.setTitle(seeAllTitle, for: .normal)
        seeAllButton.isHidden = !showsSeeAll
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Layout.gapTitleToCollection),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        applyFixedSizing()
    }
    
    private func applyFixedSizing() {
        if collectionHeight == nil {
            let height = collectionView.heightAnchor.constraint(equalToConstant: rowHeight)
            height.priority = .required
            height.isActive = true
            collectionHeight = height
        } else {
            collectionHeight?.constant = rowHeight
        }
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.itemSize = fixedItemSize()
            flow.invalidateLayout()
        }
    }
    
    private func fixedItemSize() -> CGSize {
        let labelsHeight =
        Constants.Layout.gapPosterToTitle
        + titleLabel.font.lineHeight
        + Constants.Layout.gapTitleToGenres
        + UIFont.montserrat(.regular, size: Constants.Text.genresFontSize).lineHeight
        + Constants.Layout.labelsBottomPadding
        
        let posterHeight = max(.zero, rowHeight - labelsHeight)
        let itemWidth = posterHeight / posterAspectHW
        return CGSize(width: floor(max(Constants.Layout.minItemWidth, itemWidth)), height: rowHeight)
    }
    
    @objc private func onSeeAll() { delegate?.moviesSectionDidTapSeeAll(self) }
    
    func collectionView(_ c: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    func collectionView(_ c: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = c.dequeueReusableCell(withReuseIdentifier: MovieCardCell.reuseId, for: indexPath) as! MovieCardCell
        let vm = items[indexPath.item]
        cell.configure(title: vm.title, genres: vm.genres, poster: vm.poster)
        return cell
    }
    
    func collectionView(_ c: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.moviesSection(self, didSelect: indexPath.item)
    }
    
    func collectionView(_ c: UICollectionView, layout l: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        fixedItemSize()
    }
}
