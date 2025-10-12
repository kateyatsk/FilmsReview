//
//  MediaListViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.09.25.
//

import UIKit

enum MediaListSource {
    case topSearch
    case recommendations
}

fileprivate enum Constants {
    enum Text {
        static let defaultTitle = "Top Searches"
    }
    
    enum Font {
        static let titleSize: CGFloat = 22
    }
    
    enum Icon {
        static let back = "arrow.backward"
        static let size: CGFloat = 22
    }
    
    enum Layout {
        static let itemHeight: CGFloat = 96
        static let backButtonTop: CGFloat = 6
        static let insets = UIEdgeInsets(top: 12, left: Spacing.xs3, bottom: 12, right: Spacing.xs3)
        static let footerHeight: CGFloat = 50
        static let footerExtraBottom: CGFloat = 60
        static let footerYOffset: CGFloat = 10
    }
    
    enum Size {
        static let minTapArea: CGFloat = 44
    }
}

protocol MediaListVCProtocol: ViewControllerProtocol {
    func displayContent(viewModel: [MediaItem])
}

final class MediaListViewController: UIViewController,
                                     MediaListVCProtocol,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    var items: [MediaItem] = [] {
        didSet { if isViewLoaded { collectionView.reloadData() } }
    }
    
    var titleText: String = Constants.Text.defaultTitle {
        didSet { if isViewLoaded { titleLabel.text = titleText } }
    }
    
    var listSource: MediaListSource = .recommendations
    
    func configure(title: String? = nil, items: [MediaItem]? = nil, source: MediaListSource? = nil) {
        if let title { self.titleText = title }
        if let items { self.items = items }
        if let source { self.listSource = source }
    }
    
    private var isLoadingNextPage = false
     
     private lazy var loadingFooter: UIActivityIndicatorView = {
         let indicator = UIActivityIndicatorView(style: .medium)
         indicator.color = .gray
         indicator.hidesWhenStopped = true
         indicator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height:  Constants.Layout.footerHeight)
         return indicator
     }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: Constants.Icon.size, weight: .regular)
        button.setImage(UIImage(systemName: Constants.Icon.back, withConfiguration: config), for: .normal)
        button.tintColor = .titlePrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onBackTap), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.bold, size: Constants.Font.titleSize)
        label.textColor = .titlePrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Spacing.xs4
        layout.sectionInset = Constants.Layout.insets
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(MediaRowCell.self, forCellWithReuseIdentifier: MediaRowCell.reuseId)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        collectionView.addSubview(loadingFooter)
        collectionView.contentInset.bottom = view.safeAreaInsets.bottom + Constants.Layout.footerExtraBottom
        updateLoadingFooterFrame()
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           updateLoadingFooterFrame()
       }
       
       private func updateLoadingFooterFrame() {
           loadingFooter.frame.origin.y = collectionView.contentSize.height + Constants.Layout.footerYOffset
       }
    
    private func setupLayout() {
        view.backgroundColor = .white
        view.addSubviews(backButton, titleLabel, collectionView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.backButtonTop),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.Size.minTapArea),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Size.minTapArea),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: Spacing.xs4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Spacing.xs3),
            
            collectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Spacing.xs4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        titleLabel.text = titleText
        collectionView.delegate = self
    }
    
    @objc private func onBackTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func displayContent(viewModel: [MediaItem]) {
        if items.isEmpty {
            self.items = viewModel
        } else {
            let existingIDs = Set(items.map(\.tmdbId))
            let newUnique = viewModel.filter { !existingIDs.contains($0.tmdbId) }
            self.items.append(contentsOf: newUnique)
        }
        collectionView.reloadData()
        stopFooterLoading()
    }

    private func startFooterLoading() {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        loadingFooter.startAnimating()
        updateLoadingFooterFrame()
    }
    
    private func stopFooterLoading() {
        isLoadingNextPage = false
        loadingFooter.stopAnimating()
    }
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: MediaRowCell.reuseId, for: indexPath) as! MediaRowCell
        cell.configure(with: items[indexPath.item])
        cell.onPlay = { [weak self] in }
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cv.deselectItem(at: indexPath, animated: true)
        
        let item = items[indexPath.item]
        (router as? HomeRouterProtocol)?.showMovieDetails(vm: item)
    }
    
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.bounds.width - Constants.Layout.insets.left - Constants.Layout.insets.right
        return .init(width: width, height: Constants.Layout.itemHeight)
    }
}

extension MediaListViewController: UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item == items.count - 1 {
            startFooterLoading()
            (interactor as? HomeInteractor)?.loadNextMediaListPageIfNeeded(currentIndex: indexPath.item, source: listSource)
        }
    }
}
