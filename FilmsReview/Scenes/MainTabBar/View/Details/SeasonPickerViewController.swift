//
//  SeasonPickerViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 12.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Picker {
        static let itemHeight: CGFloat = 52
        static let horizontalInset: CGFloat = 40
        static let verticalHeightLimit: CGFloat = 0.60
        static let listSpacing: CGFloat = 8
    }
    enum CloseButton {
        static let diameter: CGFloat = 52
        static let bottomOffset: CGFloat = 55
        static let cornerRadius: CGFloat = 26
        static let systemImageName = "xmark"
    }
    enum Cell {
        static let contentCornerRadius: CGFloat = 12
        static let sideInset: CGFloat = 16
        static let checkmarkTrailing: CGFloat = 16
        static let minHeight: CGFloat = 52
        static let checkmarkSystemName = "checkmark"
        static let unselectedAlpha: CGFloat = 0.92
        static let numberOfLines = 1
    }
}

final class SeasonPickerViewController: UIViewController {
    private let seasons: [String]
    private var selectedIndex: Int
    
    var onPick: ((Int) -> Void)?
    
    private lazy var blurOverlay = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.CloseButton.systemImageName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .buttonPrimary
        button.layer.cornerRadius = Constants.CloseButton.cornerRadius
        button.addTarget(self, action: #selector(dismissOverlay), for: .touchUpInside)
        return button
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.Picker.listSpacing
        layout.minimumInteritemSpacing = .zero
        return layout
    }()
    
    private lazy var seasonCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.showsVerticalScrollIndicator = false
        view.register(SeasonCell.self, forCellWithReuseIdentifier: SeasonCell.reuseID)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private var collectionHeightConstraint: NSLayoutConstraint!
    private var didSetInitialLayout = false
    
    init(seasons: [String], selectedIndex: Int) {
        self.seasons = seasons
        self.selectedIndex = max(0, min(selectedIndex, max(0, seasons.count - 1)))
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [blurOverlay, closeButton, seasonCollectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.addSubviews(blurOverlay)
        blurOverlay.contentView.addSubviews(seasonCollectionView, closeButton)
        
        NSLayoutConstraint.activate([
            blurOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            blurOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            seasonCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            seasonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Picker.horizontalInset),
            seasonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Picker.horizontalInset),
            
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.CloseButton.bottomOffset),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.CloseButton.diameter),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
        
        collectionHeightConstraint = seasonCollectionView.heightAnchor.constraint(equalToConstant: .zero)
        collectionHeightConstraint.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = view.bounds.width - Constants.Picker.horizontalInset * 2
        if layout.itemSize.width != width {
            layout.itemSize = CGSize(width: width, height: Constants.Picker.itemHeight)
            layout.invalidateLayout()
        }
        
        if !didSetInitialLayout && view.window != nil {
            didSetInitialLayout = true
            updateCollectionHeight()
        }
    }
    
    private func updateCollectionHeight() {
        let rows = seasons.count
        let totalHeight = CGFloat(rows) * Constants.Picker.itemHeight
        + CGFloat(max(0, rows - 1)) * Constants.Picker.listSpacing
        
        let maxHeight = view.bounds.height * Constants.Picker.verticalHeightLimit
        collectionHeightConstraint.constant = min(maxHeight, totalHeight)
        seasonCollectionView.isScrollEnabled = totalHeight > maxHeight
        view.layoutIfNeeded()
    }
    
    @objc private func dismissOverlay() { dismiss(animated: true) }
}

extension SeasonPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { seasons.count }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: SeasonCell.reuseID, for: indexPath) as! SeasonCell
        cell.configure(title: seasons[indexPath.item], selected: indexPath.item == selectedIndex)
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        onPick?(selectedIndex)
        dismiss(animated: true)
    }
}

private final class SeasonCell: UICollectionViewCell {
    static let reuseID = "SeasonCell"
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = Constants.Cell.numberOfLines
        return label
    }()
    
    private let checkmark: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: Constants.Cell.checkmarkSystemName))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .buttonPrimary
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubviews(title, checkmark)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Cell.sideInset),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Cell.sideInset),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Cell.checkmarkTrailing),
            checkmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Cell.minHeight)
        ])
        
        contentView.layer.cornerRadius = Constants.Cell.contentCornerRadius
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) { nil }
    
    func configure(title text: String, selected: Bool) {
        title.text = text
        title.font = selected ? .montserrat(.bold, size: Size.s.height) : .montserrat(.semiBold, size: Size.s.height)
        title.textColor = selected ? .buttonPrimary : .white.withAlphaComponent(Constants.Cell.unselectedAlpha)
        checkmark.isHidden = !selected
    }
}
