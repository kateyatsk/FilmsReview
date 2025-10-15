//
//
//  FavoriteViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

private enum Constants {
    enum Text {
        static let title = "Favorites"
        static let empty = "No favorites yet"
    }
    enum Layout {
        static let topInset: CGFloat = 12
        static let hPad: CGFloat = 16
        static let emptyLabelHPad: CGFloat = 24
    }
}

protocol FavoriteVCProtocol: ViewControllerProtocol {
    func show(items: [MediaItem])
    func setLoading(_ loading: Bool)
}

final class FavoriteViewController: UIViewController, FavoriteVCProtocol, MediaSectionViewDelegate {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private let section = MediaVerticalSectionView()
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = Constants.Text.empty
        l.font = .montserrat(.medium, size: FontSize.subtitle)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        section.delegate = self
        section.setTitle(Constants.Text.title)
        section.setScrollable(true)
        section.setShowsSeeAll(false)
        section.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(section)
        NSLayoutConstraint.activate([
            section.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.topInset),
            section.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.hPad),
            section.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.hPad),
            section.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        section.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: section.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: section.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: section.leadingAnchor, constant: Constants.Layout.emptyLabelHPad),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: section.trailingAnchor, constant: -Constants.Layout.emptyLabelHPad)
        ])
        
        section.showSkeleton()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func reload() {
        emptyLabel.isHidden = true
        if let uid = FirebaseAuthManager.shared.getCurrentUID(){
            (interactor as? FavoriteInteractorProtocol)?.load(uid: uid)
        } else {
            section.hideSkeleton()
            section.items = []
            emptyLabel.isHidden = false
        }
    }
    
    func show(items: [MediaItem]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.section.hideSkeleton()
            self.section.items = items
            self.emptyLabel.isHidden = !items.isEmpty
        }
    }
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if loading {
                self.emptyLabel.isHidden = true
                self.section.showSkeleton()
            } else {
                self.section.hideSkeleton()
            }
        }
    }
    
    func mediaSectionDidTapSeeAll(_ view: MediaVerticalSectionView) {}
    func mediaSection(_ view: MediaVerticalSectionView, didTapPlay index: Int) {}
    func mediaSection(_ view: MediaVerticalSectionView, didSelect index: Int) {
        guard index >= 0, index < section.items.count else { return }
        let item = section.items[index]
        (router as? FavoriteRouterProtocol)?.openDetails(item, from: self)
    }
}
