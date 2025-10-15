//
//  SearchViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

fileprivate enum Constants {
    enum Text {
        static let title = "Search"
        static let placeholder = "Search…"
        static let cancel = "Cancel"
        static let topTitle = "Top Searches"
        static let resultsTitle = "Results"
        static let noResults = "No results found"
        static let tryAnother = "Try another search"
    }
    enum Layout {
        static let contentInset: CGFloat = Spacing.xs3
        static let verticalGap: CGFloat = 16
        static let searchHeight: CGFloat = 44
        static let searchCorner: CGFloat = 14
        static let searchIconSize: CGFloat = 18
    }
    enum Search {
        static let debounceInterval: TimeInterval = 0.6
    }
}

protocol SearchVCProtocol: ViewControllerProtocol {
    func displayTop(items: [MediaItem])
    func displayResults(items: [MediaItem])
    func displayError(_ error: Error)
}

final class SearchViewController: UIViewController, SearchVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .montserrat(.bold, size: FontSize.title)
        l.textColor = .titlePrimary
        l.text = Constants.Text.title
        return l
    }()

    private let searchContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = Constants.Layout.searchCorner
        return v
    }()

    private let searchIcon: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .secondaryLabel
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let searchField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .montserrat(.regular, size: FontSize.body)
        tf.textColor = .label
        tf.returnKeyType = .search
        tf.clearButtonMode = .never
        tf.placeholder = Constants.Text.placeholder
        return tf
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(Constants.Text.cancel, for: .normal)
        b.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        b.setTitleColor(.titlePrimary, for: .normal)
        b.isHidden = true
        b.alpha = 0
        return b
    }()

    private let sectionsContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var topSection: MediaVerticalSectionView = {
        let v = MediaVerticalSectionView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle(Constants.Text.topTitle)
        v.setShowsSeeAll(false)
        v.setScrollable(true)
        v.isHidden = false
        return v
    }()

    private lazy var resultsSection: MediaVerticalSectionView = {
        let v = MediaVerticalSectionView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle(Constants.Text.resultsTitle)
        v.setShowsSeeAll(false)
        v.setScrollable(true)
        v.isHidden = true
        return v
    }()

    private let noResultsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.medium, size: FontSize.caption)
        label.textColor = .secondaryLabel
        label.text = Constants.Text.noResults
        label.textAlignment = .center
        return label
    }()

    private let noResultsSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .montserrat(.regular, size: FontSize.body)
        label.textColor = .tertiaryLabel
        label.text = Constants.Text.tryAnother
        label.textAlignment = .center
        return label
    }()

    private let debouncer = Debouncer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        bind()
        hideKeyboardWhenTappedAround()
        topSection.showSkeleton()
        (interactor as? SearchInteractorProtocol)?.loadTopSearches()
    }

    private func setupLayout() {
        view.addSubviews(titleLabel, searchContainer, sectionsContainer)

        searchContainer.addSubviews(searchIcon, searchField, cancelButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.contentInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.contentInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.contentInset),

            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Layout.verticalGap),
            searchContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            searchContainer.heightAnchor.constraint(equalToConstant: Constants.Layout.searchHeight),

            searchIcon.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: Spacing.xs3),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: Constants.Layout.searchIconSize),
            searchIcon.heightAnchor.constraint(equalToConstant: Constants.Layout.searchIconSize),

            cancelButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -Spacing.xs3),
            cancelButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),

            searchField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: Spacing.xs3),
            searchField.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -Spacing.xs3),
            searchField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),

            sectionsContainer.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: Constants.Layout.verticalGap),
            sectionsContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sectionsContainer.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            sectionsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.xs2)
        ])

        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        searchField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        searchField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        sectionsContainer.addSubviews(topSection, resultsSection, noResultsView)
        noResultsView.addSubviews(noResultsLabel, noResultsSubtitle)

        for v in [topSection, resultsSection] {
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: sectionsContainer.topAnchor),
                v.leadingAnchor.constraint(equalTo: sectionsContainer.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: sectionsContainer.trailingAnchor),
                v.bottomAnchor.constraint(equalTo: sectionsContainer.bottomAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            noResultsView.topAnchor.constraint(equalTo: sectionsContainer.topAnchor),
            noResultsView.leadingAnchor.constraint(equalTo: sectionsContainer.leadingAnchor),
            noResultsView.trailingAnchor.constraint(equalTo: sectionsContainer.trailingAnchor),
            noResultsView.bottomAnchor.constraint(equalTo: sectionsContainer.bottomAnchor),

            noResultsLabel.centerYAnchor.constraint(equalTo: noResultsView.centerYAnchor, constant: -Spacing.xs3),
            noResultsLabel.leadingAnchor.constraint(equalTo: noResultsView.leadingAnchor),
            noResultsLabel.trailingAnchor.constraint(equalTo: noResultsView.trailingAnchor),

            noResultsSubtitle.topAnchor.constraint(equalTo: noResultsLabel.bottomAnchor, constant: Spacing.xs4),
            noResultsSubtitle.leadingAnchor.constraint(equalTo: noResultsView.leadingAnchor),
            noResultsSubtitle.trailingAnchor.constraint(equalTo: noResultsView.trailingAnchor)
        ])

        topSection.delegate = self
        resultsSection.delegate = self
    }

    private func bind() {
        searchField.addTarget(self, action: #selector(onSearchChanged), for: .editingChanged)
        searchField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        searchField.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        searchField.delegate = self

        cancelButton.addTarget(self, action: #selector(onCancelTap), for: .touchUpInside)
    }

    @objc private func editingBegan() { setCancel(visible: true) }

    @objc private func editingEnded() {
        if (searchField.text ?? "").isEmpty { setCancel(visible: false) }
    }

    @objc private func onCancelTap() {
        searchField.text = ""
        searchField.resignFirstResponder()
        setCancel(visible: false)
        showTop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setCancel(visible: Bool) {
        cancelButton.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.cancelButton.alpha = visible ? 1 : 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.cancelButton.isHidden = !visible
        }
    }

    private func showTop() {
        debouncer.cancel()
        resultsSection.hideSkeleton()
        resultsSection.isHidden = true
        noResultsView.isHidden = true

        topSection.isHidden = false
        if topSection.items.isEmpty { topSection.showSkeleton() }
        (interactor as? SearchInteractorProtocol)?.loadTopSearches()
    }

    private func showResults() {
        topSection.isHidden = true
        resultsSection.isHidden = false
        noResultsView.isHidden = true
        resultsSection.showSkeleton()
    }

    private func showNoResults() {
        topSection.isHidden = true
        resultsSection.isHidden = true
        noResultsView.isHidden = false
    }

    @objc private func onSearchChanged() {
        let query = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if query.isEmpty {
            showTop()
            return
        }

        showResults()
        debouncer.schedule(after: Constants.Search.debounceInterval) { [weak self] in
            guard let self else { return }
            await (self.interactor as? SearchInteractorProtocol)?.search(query: query)
        }
    }

    func displayTop(items: [MediaItem]) {
        topSection.hideSkeleton()
        topSection.items = items
        if !(searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            topSection.isHidden = true
            resultsSection.isHidden = false
        }
    }

    func displayResults(items: [MediaItem]) {
        guard let q = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else {
            resultsSection.hideSkeleton()
            return
        }
        
        resultsSection.hideSkeleton()
        
        if items.isEmpty {
            showNoResults()
        } else {
            resultsSection.items = items
            topSection.isHidden = true
            resultsSection.isHidden = false
            noResultsView.isHidden = true
        }
    }

    func displayError(_ error: Error) {
        resultsSection.hideSkeleton()
        print("Search error:", error.localizedDescription)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onSearchChanged()
        return true
    }
}

extension SearchViewController: MediaSectionViewDelegate {
    func mediaSectionDidTapSeeAll(_ view: MediaVerticalSectionView) { }

    func mediaSection(_ view: MediaVerticalSectionView, didSelect index: Int) {
        let item = view.items[index]
        (router as? SearchRouterProtocol)?.openDetails(item, from: self)
    }

    func mediaSection(_ view: MediaVerticalSectionView, didTapPlay index: Int) { }
}
