//
//  MediaSectionView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Layout {
        static let itemHeight: CGFloat = 96
        static let insets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        static let gapTitleToCollection: CGFloat = 12
    }
    
    enum Text {
        static let defaultTitle = "Section"
        static let seeAll = "See All"
    }
}

protocol MediaSectionViewDelegate: AnyObject {
    func mediaSectionDidTapSeeAll(_ view: MediaVerticalSectionView)
    func mediaSection(_ view: MediaVerticalSectionView, didSelect index: Int)
    func mediaSection(_ view: MediaVerticalSectionView, didTapPlay index: Int)
}

final class MediaVerticalSectionView: UIView,
                                      UICollectionViewDataSource,
                                      UICollectionViewDelegateFlowLayout {
    
    weak var delegate: MediaSectionViewDelegate?
    
    var titleText: String = Constants.Text.defaultTitle {
        didSet { titleLabel.text = titleText }
    }
    
    var items: [MediaItem] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.collectionView.reloadData()
                self.updateHeight()
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.bold, size: FontSize.subtitle)
        label.text = titleText
        label.textColor = .titlePrimary
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.Text.seeAll, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        button.setTitleColor(.buttonPrimary, for: .normal)
        button.addTarget(self, action: #selector(onSeeAll), for: .touchUpInside)
        return button
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Spacing.xs4
        layout.sectionInset = Constants.Layout.insets
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        view.dataSource = self
        view.delegate = self
        view.register(MediaRowCell.self, forCellWithReuseIdentifier: MediaRowCell.reuseId)
        return view
    }()
    
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        addSubviews(titleLabel, seeAllButton, collectionView)
        
        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: .zero)
        collectionHeightConstraint.isActive = true
        
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
    }
    
    @objc private func onSeeAll() {
        delegate?.mediaSectionDidTapSeeAll(self)
    }
    
    private func updateHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionHeightConstraint.constant = height
    }
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: MediaRowCell.reuseId, for: indexPath) as! MediaRowCell
        let vm = items[indexPath.item]
        cell.configure(with: vm)
        cell.onPlay = { [weak self, weak cv, weak cell] in
            guard let self, let cv, let cell, let idx = cv.indexPath(for: cell)?.item else { return }
            self.delegate?.mediaSection(self, didTapPlay: idx)
        }
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.mediaSection(self, didSelect: indexPath.item)
    }
    
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: cv.bounds.width, height: Constants.Layout.itemHeight)
    }
}
