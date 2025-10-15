//
//  EpisodesSectionView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//

import UIKit

fileprivate enum Constants {
    enum Layout {
        static let numberOfLines = 2
        static let seasonButtonContentInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        static let estimatedRowHeight: CGFloat = 96
        static let gapBelowSeasonButton: CGFloat = 12
    }
    
    enum EpisodeImage {
        static let widthMultiplier: CGFloat = 1.0 / 3.0
        static let aspectHOverW: CGFloat = PosterAspect.h9x16.hOverW
    }
    
    enum Skeleton {
        static let seasonButtonWidth: CGFloat = 140
        static let rowCount = 3
        static let rowHeight: CGFloat = 100
        static let firstRowTop: CGFloat = 20
        static let rowVerticalStep: CGFloat = 110
        
        static let containerCornerRadius = CornerRadius.m
        static let containerBackground: UIColor = .systemGray6
        
        static let imageLeading: CGFloat = 12
        static let imageWidthMultiplier: CGFloat = 0.3
        
        static let textLeadingToImage: CGFloat = 12
        static let textTop: CGFloat = 20
        static let textTrailing: CGFloat = -12
        static let textHeight: CGFloat = 16
    }
    
    enum Text {
        static let bodyFont = UIFont.montserrat(.semiBold, size: 14)
        static let seasonArrow = " ▾"
        
        static let more = "More"
        static let less = "Less"
    }
    
    enum Animation {
        static let expandCollapseDuration: TimeInterval = 0.25
    }
}

final class EpisodesSectionView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var onSelectEpisode: ((Int) -> Void)?
    var onSeasonChanged: ((Int) -> Void)?
    
    private(set) var seasons: [String] = []
    private(set) var episodes: [EpisodeVM] = []
    var selectedSeasonIndex: Int = 0
    
    private var expandedRows = Set<Int>()
    
    private var skeletonContainers: [UIView] = []
    
    private lazy var seasonButtonSkeleton: SkeletonView = {
        let view = SkeletonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.l
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var seasonButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = Constants.Text.bodyFont
        button.setTitleColor(.titlePrimary, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CornerRadius.l
        button.contentEdgeInsets = Constants.Layout.seasonButtonContentInsets
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSeasonPicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = Constants.Layout.estimatedRowHeight
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.reuseId)
        table.showsVerticalScrollIndicator = false
        table.delaysContentTouches = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        buildLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func buildLayout() {
        addSubviews(seasonButton, tableView, seasonButtonSkeleton)
        
        NSLayoutConstraint.activate([
            seasonButton.topAnchor.constraint(equalTo: topAnchor),
            seasonButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            seasonButtonSkeleton.topAnchor.constraint(equalTo: seasonButton.topAnchor),
            seasonButtonSkeleton.leadingAnchor.constraint(equalTo: seasonButton.leadingAnchor),
            seasonButtonSkeleton.widthAnchor.constraint(equalToConstant: Constants.Skeleton.seasonButtonWidth),
            seasonButtonSkeleton.bottomAnchor.constraint(equalTo: seasonButton.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: seasonButton.bottomAnchor, constant: Constants.Layout.gapBelowSeasonButton),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func showSeasonButtonSkeleton() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.seasonButton.isHidden = true
            self.seasonButtonSkeleton.isHidden = false
            self.seasonButtonSkeleton.startShimmer()
        }
    }
    
    func hideSeasonButtonSkeleton() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.seasonButtonSkeleton.stopShimmer()
            self.seasonButtonSkeleton.isHidden = true
            self.seasonButton.isHidden = false
        }
    }
    
    func configure(seasons: [String], selectedSeasonIndex: Int, episodes: [EpisodeVM]) {
        if self.episodes.map(\.title) != episodes.map(\.title) {
            expandedRows.removeAll()
        }
        
        if episodes.isEmpty {
            self.seasons = seasons
            self.selectedSeasonIndex = min(max(0, selectedSeasonIndex), max(0, seasons.count - 1))
            seasonButton.isHidden = seasons.isEmpty
            if !seasons.isEmpty {
                seasonButton.setTitle("\(seasons[self.selectedSeasonIndex])\(Constants.Text.seasonArrow)", for: .normal)
                seasonButton.accessibilityLabel = seasons[self.selectedSeasonIndex]
            }
            
            self.episodes = []
            tableView.reloadData()
            
            showLoadingPlaceholder()
            return
        }
        
        hideSeasonButtonSkeleton()
        hideLoadingPlaceholder()
        
        self.seasons = seasons
        self.selectedSeasonIndex = min(max(0, selectedSeasonIndex), max(0, seasons.count - 1))
        self.episodes = episodes
        
        seasonButton.isHidden = seasons.isEmpty
        if !seasons.isEmpty {
            seasonButton.setTitle("\(seasons[self.selectedSeasonIndex])\(Constants.Text.seasonArrow)", for: .normal)
            seasonButton.accessibilityLabel = seasons[self.selectedSeasonIndex]
        }
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    func showLoadingPlaceholder() {
        guard skeletonContainers.isEmpty else { return }
        
        tableView.isHidden = true
        
        for index in 0..<Constants.Skeleton.rowCount {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.cornerRadius = Constants.Skeleton.containerCornerRadius
            container.backgroundColor = Constants.Skeleton.containerBackground
            addSubview(container)
            
            let imageSkeleton = SkeletonView()
            imageSkeleton.translatesAutoresizingMaskIntoConstraints = false
            
            let textSkeleton = SkeletonView()
            textSkeleton.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubviews(imageSkeleton, textSkeleton)
            
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(
                    equalTo: seasonButton.bottomAnchor,
                    constant: CGFloat(index) * Constants.Skeleton.rowVerticalStep + Constants.Skeleton.firstRowTop
                ),
                container.leadingAnchor.constraint(equalTo: leadingAnchor),
                container.trailingAnchor.constraint(equalTo: trailingAnchor),
                container.heightAnchor.constraint(equalToConstant: Constants.Skeleton.rowHeight),
                
                imageSkeleton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Constants.Skeleton.imageLeading),
                imageSkeleton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                imageSkeleton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: Constants.Skeleton.imageWidthMultiplier),
                imageSkeleton.heightAnchor.constraint(equalTo: imageSkeleton.widthAnchor, multiplier: Constants.EpisodeImage.aspectHOverW),
                
                textSkeleton.leadingAnchor.constraint(equalTo: imageSkeleton.trailingAnchor, constant: Constants.Skeleton.textLeadingToImage),
                textSkeleton.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Skeleton.textTop),
                textSkeleton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: Constants.Skeleton.textTrailing),
                textSkeleton.heightAnchor.constraint(equalToConstant: Constants.Skeleton.textHeight)
            ])
            
            imageSkeleton.startShimmer()
            textSkeleton.startShimmer()
            skeletonContainers.append(container)
        }
    }
    
    func hideLoadingPlaceholder() {
        skeletonContainers.forEach { $0.removeFromSuperview() }
        skeletonContainers.removeAll()
        tableView.isHidden = false
    }
    
    @objc private func openSeasonPicker() {
        guard !seasons.isEmpty, let host = nearestViewController() else { return }
        let picker = SeasonPickerViewController(seasons: seasons, selectedIndex: selectedSeasonIndex)
        picker.onPick = { [weak self] index in
            guard let self else { return }
            self.selectedSeasonIndex = index
            self.seasonButton.setTitle("\(self.seasons[index])\(Constants.Text.seasonArrow)", for: .normal)
            self.seasonButton.accessibilityLabel = self.seasons[index]
            
            self.showLoadingPlaceholder()
            self.episodes = []
            self.expandedRows.removeAll()
            self.tableView.reloadData()
            
            self.onSeasonChanged?(index)
        }
        host.present(picker, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseId, for: indexPath) as? EpisodeCell else {
            return UITableViewCell()
        }
        
        let vm = episodes[indexPath.row]
        let expanded = expandedRows.contains(indexPath.row)
        cell.configure(vm, isExpanded: expanded)
        
        cell.onToggleExpand = { [weak self, weak cell] in
            guard let self, let cell, let ip = tableView.indexPath(for: cell) else { return }
            if self.expandedRows.contains(ip.row) {
                self.expandedRows.remove(ip.row)
            } else {
                self.expandedRows.insert(ip.row)
            }
            UIView.animate(withDuration: Constants.Animation.expandCollapseDuration) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectEpisode?(indexPath.row)
    }
}

final class EpisodeCell: UITableViewCell {
    static let reuseId = "EpisodeCell"
    
    var onToggleExpand: (() -> Void)?
    private var isExpanded = false
    
    private var lastTruncationKey: String = ""
    
    private lazy var episodeImageView = makeImageView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var durationLabel = makeDurationLabel()
    private lazy var descriptionLabel = makeDescriptionLabel()
    private lazy var moreButton = makeMoreButton()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, durationLabel, descriptionLabel, moreButton])
        stack.axis = .vertical
        stack.spacing = Spacing.xs5
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        buildLayout()
        setupSelectedBackground()
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        descriptionLabel.numberOfLines = Constants.Layout.numberOfLines
        moreButton.setTitle(Constants.Text.more, for: .normal)
        moreButton.isHidden = true
        
        titleLabel.text = nil
        durationLabel.text = nil
        descriptionLabel.text = nil
        
        lastTruncationKey = ""
    }
    
    private func buildLayout() {
        contentView.addSubviews(episodeImageView, textStack)
        
        NSLayoutConstraint.activate([
            episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            episodeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.xs4),
            episodeImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Constants.EpisodeImage.widthMultiplier),
            
            textStack.topAnchor.constraint(equalTo: episodeImageView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: Spacing.xs4),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.xs3),
            
            contentView.bottomAnchor.constraint(equalTo: textStack.bottomAnchor, constant: Spacing.xs4),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: episodeImageView.bottomAnchor, constant: Spacing.xs4)
        ])
        
        let aspect = episodeImageView.heightAnchor.constraint(
            equalTo: episodeImageView.widthAnchor,
            multiplier: Constants.EpisodeImage.aspectHOverW
        )
        aspect.priority = UILayoutPriority(999)
        aspect.isActive = true
        
        episodeImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        episodeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        moreButton.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupSelectedBackground() {
        let bg = UIView()
        bg.backgroundColor = UIColor.secondarySystemFill
        selectedBackgroundView = bg
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMoreVisibilityIfNeeded()
    }
    
    func configure(_ vm: EpisodeVM, isExpanded: Bool) {
        episodeImageView.image = vm.image
        titleLabel.text = vm.title
        durationLabel.text = vm.duration
        descriptionLabel.text = vm.episodeDescription
        
        self.isExpanded = isExpanded
        descriptionLabel.numberOfLines = isExpanded ? 0 : Constants.Layout.numberOfLines
        moreButton.setTitle(isExpanded ? Constants.Text.less : Constants.Text.more, for: .normal)
        
        titleLabel.isHidden = vm.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        durationLabel.isHidden = vm.duration.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        descriptionLabel.isHidden = vm.episodeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        lastTruncationKey = ""
        setNeedsLayout()
        layoutIfNeeded()
        updateMoreVisibilityIfNeeded()
    }
    
    @objc private func toggleMore() {
        isExpanded.toggle()
        descriptionLabel.numberOfLines = isExpanded ? 0 : Constants.Layout.numberOfLines
        moreButton.setTitle(isExpanded ? Constants.Text.less : Constants.Text.more, for: .normal)
        onToggleExpand?()
    }
    
    private func updateMoreVisibilityIfNeeded() {
        guard let text = descriptionLabel.text, !text.isEmpty else {
            moreButton.isHidden = true
            return
        }
        let width = max(1, descriptionLabel.bounds.width)
        let key = "\(Int(width))|\(text.count)|\(descriptionLabel.numberOfLines)"
        guard key != lastTruncationKey else { return }
        lastTruncationKey = key
        
        moreButton.isHidden = !needsTruncation(lines: Constants.Layout.numberOfLines)
    }
    
    private func needsTruncation(lines: Int) -> Bool {
        guard let text = descriptionLabel.text, !text.isEmpty else { return false }
        let width = max(1, descriptionLabel.bounds.width)
        
        let fullHeight = text.boundingHeight(
            width: width,
            font: descriptionLabel.font
        )
        
        let lineHeight = descriptionLabel.font.lineHeight
        let limitedHeight = ceil(lineHeight * CGFloat(lines))
        
        return fullHeight > limitedHeight + 1
    }
    
    private func makeImageView() -> UIImageView {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = CornerRadius.m
        v.backgroundColor = .systemGray5
        v.isAccessibilityElement = true
        v.accessibilityTraits = .image
        return v
    }
    
    private func makeTitleLabel() -> UILabel {
        let l = UILabel()
        l.font = .montserrat(.semiBold, size: FontSize.body)
        l.textColor = .titlePrimary
        l.numberOfLines = 2
        return l
    }
    
    private func makeDurationLabel() -> UILabel {
        let l = UILabel()
        l.font = .montserrat(.regular, size: FontSize.caption)
        l.textColor = .secondaryLabel
        return l
    }
    
    private func makeDescriptionLabel() -> UILabel {
        let l = UILabel()
        l.font = Constants.Text.bodyFont
        l.textColor = .systemGray2
        l.numberOfLines = Constants.Layout.numberOfLines
        l.setContentHuggingPriority(.defaultLow, for: .vertical)
        l.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return l
    }
    
    private func makeMoreButton() -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(Constants.Text.more, for: .normal)
        b.titleLabel?.font = .montserrat(.semiBold, size: FontSize.caption)
        b.setTitleColor(.titlePrimary, for: .normal)
        b.contentHorizontalAlignment = .leading
        b.addTarget(self, action: #selector(toggleMore), for: .touchUpInside)
        return b
    }
}

private extension String {
    func boundingHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let rect = (self as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.height)
    }
}
