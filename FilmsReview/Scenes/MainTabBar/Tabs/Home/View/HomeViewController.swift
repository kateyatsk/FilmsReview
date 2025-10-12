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
    
    static let suggestedSectionTitle = "Recommended for you"
    static let recommendedNavTitle = "Recommended"
    static let topSearchesTitle = "Top Searches"
}

protocol HomeVCProtocol: ViewControllerProtocol {
    func updateHeader(name: String, avatar: UIImage?)
    func displayContent(viewModel: HomeModels.ViewModel)
    func displayError(error: Error)
}

final class HomeViewController: UIViewController, HomeVCProtocol {
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
        title: Constants.suggestedSectionTitle,
        rowHeight: Size.xl6.height
    )
    private lazy var topSection = MediaVerticalSectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
        headerView.showSkeleton()
        suggestedSection.showSkeleton()
        topSection.showSkeleton()
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
            scrollView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor),
            
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
        (interactor as? HomeInteractorProtocol)?.loadInitialContent()
        (interactor as? HomeInteractorProtocol)?.loadHeader()
    }
    
    func displayContent(viewModel: HomeModels.ViewModel) {
        suggestedSection.hideSkeleton()
        topSection.hideSkeleton()
        suggestedSection.items = viewModel.recommended
        topSection.items = viewModel.topSearches
    }

    
    func updateHeader(name: String, avatar: UIImage?) {
        headerView.configure(
            avatar: avatar,
            name: name              
        )
    }
    
    func displayError(error: Error) {}
    
}

extension HomeViewController: MoviesSectionViewDelegate {
    func moviesSectionDidTapSeeAll(_ view: MoviesHorizontalSectionView) {
        guard let interactor = interactor as? HomeInteractorProtocol,
              let router = router as? HomeRouterProtocol else { return }

        let allItems = interactor.getAllRecommended()
        router.showMediaList(title: Constants.recommendedNavTitle, items: allItems, from: self, source: .recommendations)
    }
    
    func moviesSection(_ view: MoviesHorizontalSectionView, didSelect index: Int) {
        guard let router = router as? HomeRouterProtocol else { return }
        let movie = view.items[index]
        router.showMovieDetails(vm: movie)
    }
}

extension HomeViewController: MediaSectionViewDelegate {
    func mediaSectionDidTapSeeAll(_ view: MediaVerticalSectionView) {
        guard let interactor = interactor as? HomeInteractorProtocol,
              let router = router as? HomeRouterProtocol else { return }
        
        let allItems = interactor.getAllTopSearches()
        router.showMediaList(
            title: Constants.topSearchesTitle,
            items: allItems,
            from: self,
            source: .topSearch  
        )
    }
    
    func mediaSection(_ view: MediaVerticalSectionView, didSelect index: Int) {
        guard let router = router as? HomeRouterProtocol else { return }
        router.showMovieDetails(vm: view.items[index])
    }
    
    func mediaSection(_ view: MediaVerticalSectionView, didTapPlay index: Int) {
    }
}
