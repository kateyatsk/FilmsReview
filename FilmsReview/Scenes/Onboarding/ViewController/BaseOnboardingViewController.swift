//
//  BaseOnboardingViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.07.25.
//


import UIKit

protocol OnboardingViewControllerProtocol: ViewControllerProtocol {
    
}

class BaseOnboardingViewController: UIViewController, OnboardingViewControllerProtocol {
    
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let actionButton = UIButton(type: .system)
    let skipButton = UIButton(type: .system)
    let pageControl = UIPageControl()
    
    private var actionButtonWidthConstraint: NSLayoutConstraint?
    private var actionButtonHeightConstraint: NSLayoutConstraint?
    private var actionButtonPositionConstraint: NSLayoutConstraint?
    
    private var isLastPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarchy()
        setupConstraints()
        setupActions()
    }
    
    func configureContent(imageName: String,
                          title: String,
                          description: String,
                          pageIndex: Int,
                          isLastPage: Bool) {
        self.isLastPage = isLastPage
        imageView.image = UIImage(named: imageName)
        
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .secondaryLabel
        
        pageControl.numberOfPages = 3
        pageControl.currentPage = pageIndex
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemBlue
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.label, for: .normal)
        
        if isLastPage {
            actionButton.setTitle("Get Started", for: .normal)
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            actionButton.backgroundColor = .systemRed
            actionButton.layer.cornerRadius = 10
        } else {
            actionButton.setTitle("→", for: .normal)
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            actionButton.backgroundColor = .systemBlue
            actionButton.layer.cornerRadius = 30
        }
        actionButton.tintColor = .white
        
        updateDynamicButtonConstraints()
    }
    
    private func setupHierarchy() {
        [imageView, titleLabel, descriptionLabel, actionButton, skipButton, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            imageView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.safeAreaLayoutGuide.bottomAnchor, constant: 40),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
        ])
        
    }
    
    private func updateDynamicButtonConstraints() {
        actionButtonWidthConstraint?.isActive = false
        actionButtonHeightConstraint?.isActive = false
        actionButtonPositionConstraint?.isActive = false
        
        if isLastPage {
            let width = actionButton.intrinsicContentSize.width + 40
            let height = actionButton.intrinsicContentSize.height
            actionButtonWidthConstraint = actionButton.widthAnchor.constraint(equalToConstant: width)
            actionButtonHeightConstraint = actionButton.heightAnchor.constraint(equalToConstant: height)
            actionButtonPositionConstraint = actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        } else {
            actionButtonWidthConstraint = actionButton.widthAnchor.constraint(equalToConstant: 60)
            actionButtonHeightConstraint = actionButton.heightAnchor.constraint(equalToConstant: 60)
            actionButtonPositionConstraint = actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        }
        
        NSLayoutConstraint.activate([actionButtonWidthConstraint!, actionButtonHeightConstraint!,  actionButtonPositionConstraint!])
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }
    
    
    @objc func nextTapped() { }
    @objc func skipTapped() { }
    
}
