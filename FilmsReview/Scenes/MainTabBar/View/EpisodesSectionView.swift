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
        static let insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        static let estimatedRowHeight: CGFloat = 96
        static let belowSeason: CGFloat = 12
    }
    
    enum EpisodeImage {
        static let widthMultiplier: CGFloat = 1.0/3.0
    }

    enum Text {
        static let font = UIFont.montserrat(.semiBold, size: 14)
        static let arrow = " ▾"
    }
}

final class EpisodesSectionView: UIView, UITableViewDataSource, UITableViewDelegate {
    var onSelectEpisode: ((Int) -> Void)?
    var onSeasonChanged: ((Int) -> Void)?
    
    private(set) var seasons: [String] = []
    private(set) var episodes: [EpisodeVM] = []
    var selectedSeasonIndex: Int = 0
    
    private lazy var seasonButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.Text.font
        button.setTitleColor(.titlePrimary, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = CornerRadius.l
        button.contentEdgeInsets = Constants.Layout.insets
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSeasonPicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var episodeTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = Constants.Layout.estimatedRowHeight
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.delegate = self
        table.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.reuseId)
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        build()
    }
    required init?(coder: NSCoder) { nil }
    
    private func build() {
        addSubviews(seasonButton, episodeTable)
        NSLayoutConstraint.activate([
            seasonButton.topAnchor.constraint(equalTo: topAnchor),
            seasonButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            episodeTable.topAnchor.constraint(equalTo: seasonButton.bottomAnchor, constant: Constants.Layout.belowSeason),
            episodeTable.leadingAnchor.constraint(equalTo: leadingAnchor),
            episodeTable.trailingAnchor.constraint(equalTo: trailingAnchor),
            episodeTable.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(seasons: [String], selectedSeasonIndex: Int, episodes: [EpisodeVM]) {
        self.seasons = seasons
        self.selectedSeasonIndex = min(max(0, selectedSeasonIndex), max(0, seasons.count - 1))
        self.episodes = episodes

        seasonButton.isHidden = seasons.isEmpty
        if !seasons.isEmpty {
            seasonButton.setTitle("\(seasons[self.selectedSeasonIndex])\(Constants.Text.arrow)", for: .normal)
        } else {
            seasonButton.setTitle(nil, for: .normal)
        }

        episodeTable.reloadData()
    }
    
    
    @objc private func openSeasonPicker() {
        guard !seasons.isEmpty, let host = nearestViewController() else { return }
        let picker = SeasonPickerViewController(seasons: seasons, selectedIndex: selectedSeasonIndex)
        picker.onPick = { [weak self] idx in
            guard let self else { return }
            self.selectedSeasonIndex = idx
            self.seasonButton.setTitle("\(self.seasons[idx])\(Constants.Text.arrow)", for: .normal)
            self.onSeasonChanged?(idx)
        }
        host.present(picker, animated: true)
    }
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { episodes.count }
    
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: EpisodeCell.reuseId, for: indexPath) as! EpisodeCell
        cell.configure(episodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectEpisode?(indexPath.row)
    }
}

final class EpisodeCell: UITableViewCell {
    static let reuseId = "EpisodeCell"
    
    private lazy var episodeImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = CornerRadius.xl
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var episodeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.semiBold, size: FontSize.body)
        label.textColor = .titlePrimary
        label.numberOfLines = Constants.Layout.numberOfLines
        return label
    }()
    
    private lazy var duration: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Text.font
        label.textColor = .systemGray2
        label.numberOfLines = Constants.Layout.numberOfLines
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        build()
    }
    required init?(coder: NSCoder) { nil }
    
    private func build() {
        contentView.addSubviews(episodeImageView, episodeTitle, duration, descriptionLabel)
        
        NSLayoutConstraint.activate([
            episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            episodeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.xs4),
            
            episodeImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Constants.EpisodeImage.widthMultiplier),
            episodeImageView.heightAnchor.constraint(equalTo: episodeImageView.widthAnchor, multiplier: PosterAspect.h9x16.hOverW),

            episodeImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Spacing.xs4),
            
            episodeTitle.topAnchor.constraint(equalTo: episodeImageView.topAnchor),
            episodeTitle.leadingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: Constants.Layout.belowSeason),
            episodeTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            duration.topAnchor.constraint(equalTo: episodeTitle.bottomAnchor, constant: Spacing.xs5),
            duration.leadingAnchor.constraint(equalTo: episodeTitle.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: Spacing.xs5),
            descriptionLabel.leadingAnchor.constraint(equalTo: episodeTitle.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Spacing.xs4)
        ])
    }
    
    func configure(_ vm: EpisodeVM) {
        episodeImageView.image = vm.image
        episodeTitle.text = vm.title
        duration.text = vm.duration
        descriptionLabel.text = vm.episodeDescription
    }
}
