//
//  MovieDetailsViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.09.25.
//

import UIKit

fileprivate enum Tab: String, CaseIterable {
    case episodes = "Episodes"
    case about = "About"
    case review = "Reviews"
    case suggested = "Suggested"
}

fileprivate enum Constants {
    enum Layout {
        static let headerAspectHOverW: CGFloat = 10.0 / 9.0
    }
    
    enum Suggested {
        static let title = "Recommended for you"
        static let fontSize: CGFloat = 14
        static let rowHeight: CGFloat = 220
    }
    
}

protocol MovieDetailsViewControllerProtocol: ViewControllerProtocol {}

final class MovieDetailsViewController: UIViewController, MovieDetailsViewControllerProtocol, MoviesSectionViewDelegate {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    var viewModel: MediaItem? { didSet { if isViewLoaded { applyViewModel() } } }
    
    private lazy var headerView = MovieHeaderView()
    private lazy var tabsBar = SegmentsBar(titles: makeTabs(for: viewModel).map(\.rawValue))
    
    private lazy var aboutSection = AboutSectionView()
    private lazy var episodesSection = EpisodesSectionView()
    private lazy var reviewsSection = ReviewsSectionView()
    private lazy var suggestedSection: MoviesHorizontalSectionView = {
        let view = MoviesHorizontalSectionView(title: Constants.Suggested.title, fontSize: Constants.Suggested.fontSize, showsSeeAll: false, rowHeight: Constants.Suggested.rowHeight)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        buildLayout()
        wireActions()
        applyViewModel()
    }
    
    private func buildLayout() {
        view.addSubviews(
            headerView,
            tabsBar,
            aboutSection,
            episodesSection,
            reviewsSection,
            suggestedSection
        )
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.Layout.headerAspectHOverW),
            
            tabsBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Spacing.xs4),
            tabsBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            aboutSection.topAnchor.constraint(equalTo: tabsBar.bottomAnchor, constant: Spacing.xs3),
            aboutSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            aboutSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            aboutSection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            episodesSection.topAnchor.constraint(equalTo: tabsBar.bottomAnchor, constant: Spacing.xs3),
            episodesSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            episodesSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            episodesSection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            reviewsSection.topAnchor.constraint(equalTo: tabsBar.bottomAnchor, constant: Spacing.xs3),
            reviewsSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            reviewsSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            reviewsSection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            suggestedSection.topAnchor.constraint(equalTo: tabsBar.bottomAnchor, constant: Spacing.xs3),
            suggestedSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            suggestedSection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            suggestedSection.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        aboutSection.isHidden = true
        episodesSection.isHidden = true
        reviewsSection.isHidden = true
        suggestedSection.isHidden = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func wireActions() {
        headerView.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        headerView.onPlay = { }
        headerView.onLike = { _ in }
        
        suggestedSection.delegate = self
        
        episodesSection.onSelectEpisode = { _ in  }
        episodesSection.onSeasonChanged = { [weak self] idx in
            _ = (self, idx)
        }
        
        tabsBar.onSelect = { [weak self] idx in
            guard let self else { return }
            let tabs = self.makeTabs(for: self.viewModel)
            guard tabs.indices.contains(idx) else { return }
            self.show(tab: tabs[idx])
        }
    }
    
    private func applyViewModel() {
        guard let vm = viewModel else { return }
        
        headerView.configure(
            poster: vm.poster,
            title: vm.title,
            overview: vm.overview,
            metaChips: vm.metaChips
        )
        
        aboutSection.configure(overview: vm.overview, cast: vm.cast)
        
        episodesSection.configure(
            seasons: vm.seasonTitles,
            selectedSeasonIndex: 0,
            episodes: vm.episodes
        )
        
        reviewsSection.configure(reviews: vm.reviews)
        
        suggestedSection.items = vm.suggested
        suggestedSection.isHidden = vm.suggested.isEmpty
        
        let tabs = makeTabs(for: vm)
        let initial = initialTab(for: vm)
        if let idx = tabs.firstIndex(of: initial) {
            tabsBar.select(index: idx, animated: false)
            show(tab: initial)
        }
    }
    
    private func makeTabs(for vm: MediaItem?) -> [Tab] {
        let hasEpisodes  = !(vm?.seasonTitles.isEmpty ?? true)
        let hasSuggested = !(vm?.suggested.isEmpty ?? true)
        return [
            hasEpisodes ? .episodes : nil,
            .about,
            .review,
            hasSuggested ? .suggested : nil
        ].compactMap { $0 }
    }
    
    private func initialTab(for vm: MediaItem) -> Tab {
        vm.seasonTitles.isEmpty ? .about : .episodes
    }
    
    private func show(tab: Tab) {
        aboutSection.isHidden = tab != .about
        episodesSection.isHidden = tab != .episodes
        reviewsSection.isHidden = tab != .review
        suggestedSection.isHidden = !(tab == .suggested && !suggestedSection.items.isEmpty)
    }
    
    func moviesSectionDidTapSeeAll(_ view: MoviesHorizontalSectionView) {}
    
    func moviesSection(_ view: MoviesHorizontalSectionView, didSelect index: Int) {
        guard view === suggestedSection,
              index >= 0, index < suggestedSection.items.count else { return }
        let item = suggestedSection.items[index]
        (router as? MainTabBarRouterProtocol)?.openDetails(for: item, from: self)
    }
}

