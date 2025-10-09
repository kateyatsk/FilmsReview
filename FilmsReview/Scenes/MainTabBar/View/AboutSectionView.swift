//
//  AboutSectionView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//


import UIKit

fileprivate enum Constants {
    enum Layout {
        static let numberOfLines: Int = 3
        static let unlimitedNumberOfLines: Int = 0
        static let overlayAlpha: CGFloat = 0.5
    }
    
    enum Text {
        static let titleDescription = "Story Line"
        static let more = "More"
        static let less = "Less"
        static let cast = "Cast"
        static let noOverview = "No description available."
    }
    
    enum ChipMetrics {
        static let font: UIFont = .montserrat(.semiBold, size: 14)
        static let avatar: CGFloat = 32
        static let left: CGFloat = 8
        static let gap: CGFloat = 8
        static let right: CGFloat = 12
        
        static var hPad: CGFloat { left + gap + right }
        static let vPad: CGFloat = 20
        static let minTextSpace: CGFloat = 24
        
        static let shareRegular: CGFloat = 0.45
        static let shareCompact: CGFloat = 0.65
        
        static let borderWidth: CGFloat = 2
        static let containerCorner: CGFloat = 26
        static let avatarCorner: CGFloat = avatar / 2
    }
    
    enum Animation {
        static let expandCollapseDuration: TimeInterval = 0.25
    }
}

final class AboutSectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.titleDescription
        label.font = .montserrat(.bold, size: FontSize.subtitle)
        label.textColor = .titlePrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.Layout.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.Text.more, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: FontSize.caption)
        button.setTitleColor(.titlePrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var castTitle: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.cast
        label.font = .montserrat(.bold, size: FontSize.subtitle)
        label.textColor = .titlePrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Spacing.xs4
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(CastChipCell.self, forCellWithReuseIdentifier: CastChipCell.reuseID)
        return view
    }()
    
    private var isExpanded = false
    private var cast: [CastVM] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(titleLabel, textLabel, moreButton, castTitle, castCollectionView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs4),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            moreButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            moreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            castTitle.topAnchor.constraint(equalTo: moreButton.bottomAnchor, constant: Spacing.xs3),
            castTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            castCollectionView.topAnchor.constraint(equalTo: castTitle.bottomAnchor, constant: Spacing.xs4),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            castCollectionView.heightAnchor.constraint(equalToConstant: Size.xl3.height),
            castCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        moreButton.addTarget(self, action: #selector(toggleMore), for: .touchUpInside)
    }
    
    @objc private func toggleMore() {
        isExpanded.toggle()
        
        UIView.performWithoutAnimation {
            moreButton.setTitle(isExpanded ? Constants.Text.less : Constants.Text.more, for: .normal)
            moreButton.layoutIfNeeded()
        }
        
        textLabel.numberOfLines = isExpanded ? Constants.Layout.unlimitedNumberOfLines : Constants.Layout.numberOfLines
        UIView.animate(withDuration: Constants.Animation.expandCollapseDuration,
                       delay: .zero,
                       options: [.curveEaseInOut],
                       animations: {
            self.superview?.layoutIfNeeded()
        })
    }
    
    func configure(overview: String, cast: [CastVM]) {
        self.cast = cast
        
        let trimmed = overview.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasOverview = !trimmed.isEmpty
        
        textLabel.text = hasOverview ? overview : Constants.Text.noOverview
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = hasOverview
        ? (isExpanded ? Constants.Layout.unlimitedNumberOfLines : Constants.Layout.numberOfLines)
        : Constants.Layout.unlimitedNumberOfLines
        
        moreButton.isHidden = !hasOverview
        
        let isEmpty = cast.isEmpty
        castTitle.isHidden = isEmpty
        castCollectionView.isHidden = isEmpty
        
        castCollectionView.reloadData()
    }
    
    func collectionView(_ cv: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { cast.count }
    
    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: CastChipCell.reuseID, for: indexPath) as! CastChipCell
        cell.configure(vm: cast[indexPath.item])
        return cell
    }
    
    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let name = cast[indexPath.item].name as NSString
        let textW = ceil(name.size(withAttributes: [.font: Constants.ChipMetrics.font]).width)
        
        let height = ceil(max(Constants.ChipMetrics.avatar, Constants.ChipMetrics.font.lineHeight) + Constants.ChipMetrics.vPad)
        let ideal  = ceil(Constants.ChipMetrics.avatar + Constants.ChipMetrics.hPad + textW)
        
        let available = cv.bounds.width > .zero ? cv.bounds.width : Size.xl6.width
        let share = (cv.traitCollection.horizontalSizeClass == .regular)
        ? Constants.ChipMetrics.shareRegular : Constants.ChipMetrics.shareCompact
        let maxW = floor(available * share)
        let minW = max(height, Constants.ChipMetrics.avatar + Constants.ChipMetrics.hPad + Constants.ChipMetrics.minTextSpace)
        
        let width = min(max(ideal, minW), maxW)
        return CGSize(width: width, height: height)
    }
}

final class CastChipCell: UICollectionViewCell {
    static let reuseID = "CastChipCell"
    
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.titlePrimary.withAlphaComponent(Constants.Layout.overlayAlpha)
        view.layer.cornerRadius = Constants.ChipMetrics.containerCorner
        return view
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.ChipMetrics.avatarCorner
        view.layer.borderWidth = Constants.ChipMetrics.borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.ChipMetrics.font
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
    }
    required init?(coder: NSCoder) { nil }
    
    private func setupLayout() {
        contentView.addSubview(container)
        container.addSubviews(avatar, name)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            avatar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Constants.ChipMetrics.left),
            avatar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: Constants.ChipMetrics.avatar),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),
            
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: Constants.ChipMetrics.gap),
            name.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -Constants.ChipMetrics.right),
            name.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    func configure(vm: CastVM) {
        avatar.image = vm.avatar
        name.text = vm.name
    }
}

struct CastVM {
    let avatar: UIImage?
    let name: String
}
