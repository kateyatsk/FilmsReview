//
//  OnboardingViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 4.07.25.
//


import UIKit

protocol OnboardingViewControllerProtocol: ViewControllerProtocol {
    func updatePageControl(currentPage: Int)
    func toggleSkipButton(hidden: Bool)
    func navigateToMainApp()
}

class OnboardingViewController: UIViewController {
    
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private let slides = Onboarding.slides
    private var currentIndex = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(OnboardingSlideCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .titlePrimary
        pc.pageIndicatorTintColor = .systemGray4
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(OnboardingConstants.ViewController.skipButtonTitle, for: .normal)
        button.titleLabel?.font = .montserrat(.medium, size: OnboardingConstants.ViewController.skipButtonFontSize)
        button.setTitleColor(.titlePrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupHierarchy()
        setupConstraints()
        
        pageControl.numberOfPages = slides.count
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        
    }
    
    private func setupHierarchy() {
        view.addSubviews(collectionView, pageControl, skipButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                pageControl.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -OnboardingConstants.ViewController.pageControlBottom
                ),
                pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                skipButton.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -OnboardingConstants.ViewController.skipButtonTrailing
                ),
                skipButton.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: OnboardingConstants.ViewController.skipButtonTop
                )
            ]
        )
    }
    
    
    @objc private func skipTapped() {
        (interactor as? OnboardingInteractorProtocol)?.skipTapped()
    }
    
    private func scrollToNextSlide() {
        let nextIndex = currentIndex + 1
        if nextIndex < slides.count {
            let indexPath = IndexPath(item: nextIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentIndex = nextIndex
            (interactor as? OnboardingInteractorProtocol)?.didScrollToSlide(at: nextIndex)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? OnboardingSlideCell else {
            return UICollectionViewCell()
        }
        
        let slide = slides[indexPath.item]
        let isLast = indexPath.item == slides.count - 1
        
        cell.configure(
            imageName: slide.image,
            title: slide.title,
            description: slide.description,
            isLast: isLast,
            action: { [weak self] in
                if isLast {
                    (self?.interactor as? OnboardingInteractorProtocol)?.skipTapped()
                } else {
                    self?.scrollToNextSlide()
                }
            }
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / view.bounds.width)
        currentIndex = index
        (interactor as? OnboardingInteractorProtocol)?.didScrollToSlide(at: index)
    }
}


    
extension OnboardingViewController: OnboardingViewControllerProtocol {

    func updatePageControl(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    func toggleSkipButton(hidden: Bool) {
        skipButton.isHidden = hidden
    }
    
    func navigateToMainApp() {
        (router as? OnboardingRouterProtocol)?.routeToMainApp()
    }
}
