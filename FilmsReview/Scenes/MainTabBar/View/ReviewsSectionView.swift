//
//  ReviewsSectionView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//

import UIKit

struct ReviewVM {
    let avatar: UIImage?
    let author: String
    let text: String
    let rating: Double
}

fileprivate enum Constants {
    enum Text {
        static let headerTitle = "Reviews"
        static let emptyState  = "No reviews yet"
        static let more = "More"
        static let less = "Less"
    }

    enum Layout {
        static let lineSpacing: CGFloat = 2
        static let nameToBodyGap: CGFloat = 6
        static let trailingGapBetweenNameAndRating: CGFloat = 12
        static let padding: CGFloat = 14
        
        static let avatarWidthMultiplier: CGFloat = 0.15
        static let starIconSize: CGFloat = 18
        static let fontSize: CGFloat = 14
        
        static let unlimitedNumberOfLines: Int = 0
        static let estimatedRowHeight: CGFloat = 120
        
        static let collapsedLines: Int = 2
        static let numberOfLines: Int = 1
    }
}

protocol ReviewCellDelegate: AnyObject {
    func reviewCellDidToggleMore(_ cell: ReviewCell)
}

final class ReviewsSectionView: UIView, UITableViewDataSource, UITableViewDelegate, ReviewCellDelegate {
    private var reviews: [ReviewVM] = []
    private var expanded: Set<Int> = []

    private let headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.bold, size: Constants.Layout.fontSize)
        label.textColor = .titlePrimary
        label.text = Constants.Text.headerTitle
        return label
    }()

    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
        table.estimatedRowHeight = Constants.Layout.estimatedRowHeight
        table.rowHeight = UITableView.automaticDimension
        table.showsVerticalScrollIndicator = false
        return table
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        addSubviews(headerTitle, table)

        NSLayoutConstraint.activate([
            headerTitle.topAnchor.constraint(equalTo: topAnchor),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor),

            table.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: Spacing.xs4),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
            table.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        table.dataSource = self
        table.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    func configure(reviews: [ReviewVM]) {
        self.reviews = reviews
        expanded.removeAll()
        table.reloadData()
        updateEmptyState() 
    }

    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { reviews.count }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: ReviewCell.reuseID, for: indexPath) as! ReviewCell
        cell.delegate = self
        let isExpanded = expanded.contains(indexPath.row)
        cell.configure(reviews[indexPath.row], expanded: isExpanded)
        return cell
    }

    func reviewCellDidToggleMore(_ cell: ReviewCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }

        let nowExpanded: Bool
        if expanded.contains(indexPath.row) {
            expanded.remove(indexPath.row)
            nowExpanded = false
        } else {
            expanded.insert(indexPath.row)
            nowExpanded = true
        }

        cell.applyExpanded(nowExpanded)

        table.beginUpdates()
        table.endUpdates()
    }
    
    private func updateEmptyState() {
        if reviews.isEmpty {
            let label = UILabel(frame: table.bounds)
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            label.textAlignment = .center
            label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
            label.font = .montserrat(.regular, size: Constants.Layout.fontSize)
            label.textColor = .titlePrimary
            label.text = Constants.Text.emptyState
            table.backgroundView = label
            table.isScrollEnabled = false
        } else {
            table.backgroundView = nil
            table.isScrollEnabled = true
        }
    }
}

final class ReviewCell: UITableViewCell {
    static let reuseID = "ReviewCell"

    weak var delegate: ReviewCellDelegate?

    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.semiBold, size: FontSize.subtitle)
        label.textColor = .titlePrimary
        label.numberOfLines = Constants.Layout.numberOfLines
        return label
    }()
    
    private lazy var body: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.regular, size: Constants.Layout.fontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.Layout.nameToBodyGap
        return stack
    }()
    
    private lazy var star: UIImageView = {
        let view = UIImageView(image: UIImage(resource: .yellowStar))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.semiBold, size: Constants.Layout.fontSize)
        label.textColor = .label
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .montserrat(.semiBold, size: Constants.Layout.fontSize)
        button.setTitle(Constants.Text.more, for: .normal)
        button.setTitleColor(.titlePrimary, for: .normal)
        return button
    }()

    private var isExpanded = false
    private var moreHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        setupViews()
        setupConstraints()
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
   
        isExpanded = false
        body.numberOfLines = Constants.Layout.collapsedLines
        moreButton.setTitle(Constants.Text.more, for: .normal)
        updateMoreVisibility(needsMore: false)
    }

    @objc private func didTapMore() {
        delegate?.reviewCellDidToggleMore(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        avatar.layer.cornerRadius = avatar.bounds.height / 2
    }

    private func setupViews() {
        ratingStack.addArrangedSubview(star)
        ratingStack.addArrangedSubview(ratingLabel)

        contentView.addSubviews(avatar, name, moreButton, ratingStack, body)

        ratingStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupConstraints() {
        moreHeightConstraint = moreButton.heightAnchor.constraint(equalToConstant: .zero)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatar.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatar.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Constants.Layout.avatarWidthMultiplier),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: Constants.Layout.padding),
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.xs5),
            name.trailingAnchor.constraint(lessThanOrEqualTo: ratingStack.leadingAnchor, constant: -Constants.Layout.trailingGapBetweenNameAndRating),

            ratingStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ratingStack.centerYAnchor.constraint(equalTo: name.centerYAnchor),

            star.widthAnchor.constraint(equalToConstant: Constants.Layout.starIconSize),
            star.heightAnchor.constraint(equalToConstant: Constants.Layout.starIconSize),

            body.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            body.topAnchor.constraint(equalTo: name.bottomAnchor, constant: Constants.Layout.trailingGapBetweenNameAndRating),

            moreButton.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            moreButton.topAnchor.constraint(equalTo: body.bottomAnchor),
            moreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.padding),

            moreHeightConstraint
        ])
    }
    
    func configure(_ vm: ReviewVM, expanded: Bool) {
        avatar.image = vm.avatar
        name.text = vm.author

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Constants.Layout.lineSpacing
        paragraph.lineBreakMode = .byTruncatingTail

        body.attributedText = NSAttributedString(
            string: vm.text,
            attributes: [
                .font: body.font ?? .montserrat(.regular, size: Constants.Layout.fontSize),
                .foregroundColor: body.textColor ?? .label,
                .paragraphStyle: paragraph
            ]
        )

        ratingLabel.text = String(format: "%.1f", vm.rating)

        applyExpanded(expanded)

        contentView.layoutIfNeeded()
        let showMore = needsTruncation(lines: Constants.Layout.collapsedLines)
        updateMoreVisibility(needsMore: showMore)
    }

    func applyExpanded(_ expanded: Bool) {
        isExpanded = expanded
        body.numberOfLines = expanded ? Constants.Layout.unlimitedNumberOfLines : Constants.Layout.collapsedLines
        moreButton.setTitle(expanded ? Constants.Text.less : Constants.Text.more, for: .normal)
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateMoreVisibility(needsMore: Bool) {
        moreButton.isHidden = !needsMore
        if needsMore {
            if moreHeightConstraint.isActive { moreHeightConstraint.isActive = false }
        } else {
            if !moreHeightConstraint.isActive { moreHeightConstraint.isActive = true }
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    private func needsTruncation(lines: Int) -> Bool {
        guard let text = body.attributedText, body.bounds.width > .zero else { return false }

        let width = body.bounds.width

        let probe = UILabel()
        probe.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        probe.lineBreakMode = .byTruncatingHead
        probe.attributedText = text
        probe.font = body.font
        probe.frame.size = CGSize(width: width, height: .greatestFiniteMagnitude)
        probe.sizeToFit()
        let fullHeight = probe.bounds.height

        probe.numberOfLines = lines
        probe.frame.size = CGSize(width: width, height: .greatestFiniteMagnitude)
        probe.sizeToFit()
        let limitedHeight = probe.bounds.height

        return ceil(fullHeight) > ceil(limitedHeight)
    }
    
}
