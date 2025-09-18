//
//
//  HomeViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.09.25.
//
//
import UIKit

fileprivate enum Constants {
    static let stackSpacing: CGFloat = 18
    static let suggestedTitle: String = "Recommended for you"
}

protocol HomeVC: ViewControllerProtocol {}

final class HomeViewController: UIViewController, HomeVC {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var headerView = HomeHeaderView()
    private lazy var suggestedSection = MoviesHorizontalSectionView(
        title: Constants.suggestedTitle,
        rowHeight: Size.xl6.height
    )
    private lazy var topSection = MediaVerticalSectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.xs3),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.xs3),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Spacing.xs),
        ])
        
        [headerView, suggestedSection, topSection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview($0)
        }
        
        headerView.heightAnchor.constraint(equalToConstant: Size.xl3.height).isActive = true
        
        suggestedSection.delegate = self
        topSection.delegate = self
    }
    
    private func setupData() {
        headerView.configure(avatar: UIImage(named: "user_avatar"), name: "Mohit")
        
        suggestedSection.items = [
            MediaItem(
                title: "The Greatest Showman",
                poster: UIImage(named: "poster_showman"),
                metaChips: [.genre("Romance"), .genre("Drama")]
            ),
            MediaItem(
                title: "Nobody",
                poster: UIImage(named: "poster_nobody"),
                metaChips: [.genre("Thriller"), .genre("Drama")]
            ),
            MediaItem(
                title: "Joy",
                poster: UIImage(named: "poster_joy"),
                metaChips: [.genre("Family"), .genre("Drama")]
            )
        ]
        
        topSection.titleText = "Top Searches"
        topSection.items = [
            .init(title: "Bridgerton", subtitle: "Romance, Drama", poster: UIImage(named: "poster_bridgerton")),
            .init(title: "Wednesday",  subtitle: "Comedy, Fantasy", poster: UIImage(named: "poster_wednesday")),
            .init(title: "Bridgerton", subtitle: "Romance, Drama", poster: UIImage(named: "poster_bridgerton")),
            .init(title: "Wednesday",  subtitle: "Comedy, Fantasy", poster: UIImage(named: "poster_wednesday")),
        ]
    }
}

extension HomeViewController: MoviesSectionViewDelegate {
    func moviesSectionDidTapSeeAll(_ view: MoviesHorizontalSectionView) {
        let items = view.items.map { MediaItem(title: $0.title, subtitle: $0.genres, poster: $0.poster) }
        (router as? HomeRouterProtocol)?.showMediaList(title: "Recommended", items: items, from: self)
    }
    
    func moviesSection(_ view: MoviesHorizontalSectionView, didSelect index: Int) {
        let movie = view.items[index]
        let demoReviews = [
            ReviewVM(avatar: UIImage(named: "user1"), author: "Tarun Kumar", text: "Amazing! The room is good and I was very happy. Acceptable Ads allows ad formats that are nonintrusive and comply with a strict ad criteria. They help generate revenue for content creators and do not interfere with the content you are viewing. This feature is turned on by default, but you can deactivate it at any time.", rating: 4.5),
            ReviewVM(avatar: UIImage(named: "user2"), author: "Abhishek Kumar", text: "The service is on point...", rating: 5.0),
        ]
        
        let suggested: [MediaItem] = view.items.enumerated()
            .filter { $0.offset != index }
            .map { MediaItem(title: $0.element.title, poster: $0.element.poster, genres: $0.element.genres, metaChips: $0.element.metaChips) }
        
        let cast: [CastVM] = [
            CastVM(avatar: UIImage(named: "cast_peter"),  name: "Peter England"),
            CastVM(avatar: UIImage(named: "cast_rosey"),  name: "Rosey Day"),
            CastVM(avatar: UIImage(named: "cast_greg"),   name: "Greg Miles"),
            CastVM(avatar: UIImage(named: "cast_emily"),  name: "Emily Stone"),
        ]
        
        let vm = MediaItem(
            title: movie.title,
            poster: movie.poster,
            overview: "Amazing! The room is good and I was very happy. Acceptable Ads allows ad formats that are nonintrusive and comply with a strict ad criteria. The room is good and I was very happy. Acceptable Ads allows ad formats that are nonintrusive and comply with a strict ad criteria.Amazing! The room is good and I was very happy. Acceptable Ads allows ad formats that are nonintrusive and comply with a strict ad criteria. The room is good and I was very happy. Acceptable Ads allows ad formats that are nonintrusive and comply with a strict ad criteria.",
            metaChips: [
                .year("2021"),
                .season("24 season | 12 episodes"),
                .genre(movie.genres)
            ],
            seasonTitles: ["Season 1", "Season 2", "Season 3"],
            episodes: [
                EpisodeVM(image: UIImage(named: "ep1"),
                          title: "Episode 1",
                          duration: "49 min",
                          episodeDescription: "On his way home…"),
                EpisodeVM(image: UIImage(named: "ep2"),
                          title: "Episode 2",
                          duration: "56 min",
                          episodeDescription: "Lucas, Mike and Dustin…")
            ],
            reviews: demoReviews,
            suggested: suggested,
            cast: cast
        )
        
        (router as? HomeRouterProtocol)?.showMovieDetails(vm: vm)
    }

}

extension HomeViewController: MediaSectionViewDelegate {
    func mediaSectionDidTapSeeAll(_ view: MediaVerticalSectionView) {
        (router as? HomeRouterProtocol)?.showMediaList(title: view.titleText, items: view.items, from: self)
    }
    
    func mediaSection(_ view: MediaVerticalSectionView, didSelect index: Int) {
        (router as? HomeRouterProtocol)?.showMovieDetails(vm: view.items[index])
    }
    
    func mediaSection(_ view: MediaVerticalSectionView, didTapPlay index: Int) {}
}
