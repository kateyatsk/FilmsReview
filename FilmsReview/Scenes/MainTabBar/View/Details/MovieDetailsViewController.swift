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
        static let title = "Suggested"
        static let fontSize: CGFloat = 14
        static let rowHeight: CGFloat = 220
    }
}

protocol MovieDetailsViewControllerProtocol: ViewControllerProtocol {}

final class MovieDetailsViewController: UIViewController,
                                        MovieDetailsViewControllerProtocol,
                                        MoviesSectionViewDelegate {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    var viewModel: MediaItem? { didSet { if isViewLoaded { applyViewModel() } } }
    private var isEpisodesLoading = false
    
    private var didSetInitialTab = false
    
    private lazy var headerView = MovieHeaderView()
    private lazy var tabsBar = SegmentsBar(titles: makeTabs(for: viewModel).map(\.rawValue))
    
    private lazy var aboutSection = AboutSectionView()
    private lazy var episodesSection = EpisodesSectionView()
    private lazy var reviewsSection = ReviewsSectionView()
    private lazy var suggestedSection: MoviesHorizontalSectionView = {
        let view = MoviesHorizontalSectionView(
            title: Constants.Suggested.title,
            fontSize: Constants.Suggested.fontSize,
            showsSeeAll: false,
            rowHeight: Constants.Suggested.rowHeight
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        buildLayout()
        wireActions()
        applyViewModel()
        
        suggestedSection.showSkeleton(style: .details)
        
        if let item = viewModel { loadInitialData(for: item) }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func loadInitialData(for item: MediaItem) {
        (interactor as? MainTabBarInteractorProtocol)?.loadCast(for: item)
        (interactor as? MainTabBarInteractorProtocol)?.loadReviews(for: item)
        (interactor as? MainTabBarInteractorProtocol)?.loadSuggested(for: item)
        (interactor as? MainTabBarInteractorProtocol)?.readFavoriteStatus(for: item) { [weak self] isLiked in
            self?.headerView.setLiked(isLiked)
        }
        if item.mediaType == "tv" {
            isEpisodesLoading = true
            episodesSection.showLoadingPlaceholder()
            episodesSection.showSeasonButtonSkeleton()
            (interactor as? MainTabBarInteractorProtocol)?.loadTVInitial(for: item)
        }
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
    
    private func wireActions() {
        headerView.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        headerView.onPlay = { }
        headerView.onLike = { [weak self] isLiked in
            guard let self, let currentItem = self.viewModel else { return }
            (self.interactor as? MainTabBarInteractorProtocol)?
                .updateFavorite(isLiked: isLiked, for: currentItem)
        }
        
        suggestedSection.delegate = self
        
        episodesSection.onSelectEpisode = { _ in }
        episodesSection.onSeasonChanged = { [weak self] idx in
            guard let self, let item = self.viewModel else { return }
            (self.interactor as? MainTabBarInteractorProtocol)?
                .loadTVSeason(for: item, seasonIndex: idx)
        }
        
        tabsBar.onSelect = { [weak self] idx in
            guard let self else { return }
            let tabs = self.makeTabs(for: self.viewModel)
            guard tabs.indices.contains(idx) else { return }
            self.didSetInitialTab = true
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
        reviewsSection.configure(reviews: vm.reviews)
        
        if vm.suggested.isEmpty {
            suggestedSection.showSkeleton(style: .details)
            suggestedSection.items = []
        } else {
            suggestedSection.hideSkeleton()
            suggestedSection.items = vm.suggested
        }
        
        if vm.mediaType == "tv" {
            if isEpisodesLoading {
                episodesSection.showLoadingPlaceholder()
            } else {
                episodesSection.configure(
                    seasons: vm.seasonTitles,
                    selectedSeasonIndex: 0,
                    episodes: vm.episodes
                )
            }
        }
        
        let tabs = makeTabs(for: vm)
        tabsBar.titles = tabs.map(\.rawValue)
        
        if !didSetInitialTab {
            let initial = initialTab(for: vm)
            if let idx = tabs.firstIndex(of: initial) {
                tabsBar.select(index: idx, animated: false)
                show(tab: initial)
                didSetInitialTab = true
            }
        }
    }
    
    func updateTVSeasons(titles: [String], selectedIndex: Int, episodes: [EpisodeVM]) {
        if var vm = viewModel {
            vm.seasonTitles = titles
            vm.episodes = episodes
            viewModel = vm
        }
        isEpisodesLoading = false
        episodesSection.hideLoadingPlaceholder()
        episodesSection.configure(seasons: titles, selectedSeasonIndex: selectedIndex, episodes: episodes)
        
        let tabs = makeTabs(for: viewModel)
        tabsBar.titles = tabs.map(\.rawValue)
        
        if !didSetInitialTab, let idx = tabs.firstIndex(of: .episodes) {
            tabsBar.select(index: idx, animated: false)
            show(tab: .episodes)
            didSetInitialTab = true
        }
    }
    
    func updateTVSeasonEpisodes(episodes: [EpisodeVM], selectedIndex: Int) {
        episodesSection.configure(
            seasons: episodesSection.seasons,
            selectedSeasonIndex: selectedIndex,
            episodes: episodes
        )
    }
    
    private func makeTabs(for vm: MediaItem?) -> [Tab] {
        let isTV = (vm?.mediaType == "tv")
        return [
            isTV ? .episodes : nil,
            .about,
            .review,
            .suggested
        ].compactMap { $0 }
    }
    
    private func initialTab(for vm: MediaItem) -> Tab {
        (vm.mediaType == "tv") ? .episodes : .about
    }
    
    private func show(tab: Tab) {
        aboutSection.isHidden = tab != .about
        episodesSection.isHidden = tab != .episodes
        reviewsSection.isHidden = tab != .review
        suggestedSection.isHidden = tab != .suggested
    }
    
    func updateReviews(_ reviews: [ReviewVM]) {
        if var vm = viewModel { vm.reviews = reviews; viewModel = vm }
        reviewsSection.configure(reviews: reviews)
    }
    
    func updateSuggested(_ items: [MediaItem]) {
        if var vm = viewModel { vm.suggested = items; viewModel = vm }
        suggestedSection.hideSkeleton()
        suggestedSection.items = items
    }
    
    func moviesSectionDidTapSeeAll(_ view: MoviesHorizontalSectionView) {}
    
    func moviesSection(_ view: MoviesHorizontalSectionView, didSelect index: Int) {
        guard view === suggestedSection,
              index >= 0, index < suggestedSection.items.count else { return }
        let item = suggestedSection.items[index]
        (router as? MainTabBarRouterProtocol)?.openDetails(for: item, from: self)
    }
    
    func updateCast(_ cast: [CastVM]) {
        if var vm = viewModel { vm.cast = cast; viewModel = vm }
        aboutSection.configure(overview: viewModel?.overview ?? "", cast: cast)
    }
    
    private func normalizedType(_ rawType: String?) -> String? {
        guard let rawType = rawType else { return nil }
        return rawType.lowercased().contains("tv") ? "tv" : "movie"
    }

    private func normalizedIdInt(_ rawId: Any?) -> Int? {
        switch rawId {
        case let intValue as Int: return intValue
        case let optionalInt as Int?: return optionalInt
        case let stringValue as String: return Int(stringValue)
        case let optionalString as String?: return optionalString.flatMap(Int.init)
        default: return nil
        }
    }
    
}
