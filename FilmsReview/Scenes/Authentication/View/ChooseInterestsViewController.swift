//
//  ChooseInterestsViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 26.08.25.
//

import UIKit

protocol ChooseInterestsVCProtocol: ViewControllerProtocol {
    func displayLoading(_ isLoading: Bool)
    func displayGenres(_ names: [String])
}

fileprivate enum Constants {
    enum Text {
        static let screenTitle = "Choose Interests"
        static let screenSubtitle = "Choose your favorite interest to get new shows all in one place related to it"
        static let searchPlaceholder = "Search..."
        static let nextButtonTitle = "Next"
        static let language = "en-EN"
    }
    
    enum Layout {
        static let subtitleHInset: CGFloat = 32
        static let buttonHeight: CGFloat = 56
        static let borderWidth: CGFloat = 1
        static let singleLine: Int = 1
        static let multiLine: Int = 0
        static let nextButtonDisabledAlpha: CGFloat = 0.6
        static let nextButtonEnabledAlpha: CGFloat = 1.0
    }
}

final class ChooseInterestsViewController: UIViewController, ChooseInterestsVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private var allCategories: [String] = []
    private var filteredCategories: [String] = []
    private var selectedCategories: Set<String> = []
    private var isLoading = false
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = Constants.Text.screenTitle
        l.textAlignment = .center
        l.font = .montserrat(.bold, size: FontSize.largeTitle)
        l.textColor = .black
        l.numberOfLines = Constants.Layout.singleLine
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = Constants.Text.screenSubtitle
        l.textColor = .darkGray
        l.font = .montserrat(.regular, size: FontSize.body)
        l.textAlignment = .center
        l.numberOfLines = Constants.Layout.multiLine
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = Constants.Text.searchPlaceholder
        sb.delegate = self
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = CenteredFlowLayout()
        layout.minimumInteritemSpacing = Spacing.xs3
        layout.minimumLineSpacing = Spacing.xs3
        layout.estimatedItemSize = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseId)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Text.nextButtonTitle, for: .normal)
        button.backgroundColor = UIColor.titlePrimary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Spacing.s
        button.titleLabel?.font = .montserrat(.bold, size: FontSize.subtitle)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
        navigationItem.hidesBackButton = true
        hideKeyboardWhenTappedAround()
        loadGenres()
        updateNextButtonState()
    }
    
    private func setupUI() {
        view.addSubviews(
            searchBar,
            subtitleLabel,
            titleLabel,
            collectionView,
            nextButton,
            spinner
        )
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs3),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.subtitleHInset),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.subtitleHInset),
            
            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Spacing.xs3),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Spacing.xs),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs3),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs3),
            collectionView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -Spacing.xs3),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.xs),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func didTapNext() {
        let genres = Array(selectedCategories)
        (interactor as? AuthenticationInteractorProtocol)?
            .saveFavoriteGenres(genres)
    }
    
    func loadGenres(language: String = Constants.Text.language) {
        (interactor as? AuthenticationInteractorProtocol)?
            .fetchTMDBGenres(language: language)
    }
    
    func displayLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
        view.isUserInteractionEnabled = !isLoading
        updateNextButtonState()
    }
    
    func displayGenres(_ names: [String]) {
        allCategories = names
        filteredCategories = names
        selectedCategories.removeAll()
        collectionView.reloadData()
        updateNextButtonState()
    }
    
    private func updateNextButtonState() {
        let hasSelection = !selectedCategories.isEmpty
        let enabled = hasSelection && !isLoading
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled
        ? Constants.Layout.nextButtonEnabledAlpha
        : Constants.Layout.nextButtonDisabledAlpha
    }
}

extension ChooseInterestsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = filteredCategories[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseId, for: indexPath) as! CategoryCell
        cell.configure(with: category, isSelected: selectedCategories.contains(category))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = filteredCategories[indexPath.item]
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        collectionView.reloadItems(at: [indexPath])
        updateNextButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = filteredCategories[indexPath.item]
        let font = UIFont.montserrat(.medium, size: FontSize.body)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let iconSpace: CGFloat = Spacing.xs
        let horizontalPadding: CGFloat = Spacing.xs
        let totalWidth = ceil(textWidth + iconSpace + horizontalPadding)
        return CGSize(width: totalWidth, height: Size.xl.height)
    }
}

extension ChooseInterestsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCategories = searchText.isEmpty
        ? allCategories
        : allCategories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        collectionView.reloadData()
    }
}

final class CategoryCell: UICollectionViewCell {
    static let reuseId = "CategoryCell"
    
    private let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .lightGray
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .montserrat(.medium, size: FontSize.body)
        btn.contentHorizontalAlignment = .center
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = CornerRadius.m
        contentView.layer.borderWidth = Constants.Layout.borderWidth
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = .white
        
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Size.xs2.width),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Size.xs2.width),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.xs4),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.xs4)
        ])
        button.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with title: String, isSelected: Bool) {
        button.setTitle(title, for: .normal)
        if isSelected {
            let config = UIImage.SymbolConfiguration(pointSize: Size.xs4.width, weight: .medium)
            let image = UIImage(systemName: "checkmark", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: Spacing.xs4)
            button.tintColor = .titlePrimary
            button.setTitleColor(.titlePrimary, for: .normal)
            contentView.layer.borderColor = UIColor.titlePrimary.cgColor
        } else {
            button.setImage(nil, for: .normal)
            button.tintColor = .lightGray
            button.setTitleColor(.black, for: .normal)
            contentView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
