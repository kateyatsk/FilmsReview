//
//
//  AuthenticationViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import UIKit

protocol AuthenticationVCProtocol: ViewControllerProtocol {
    
}

final class AuthenticationViewController: UIViewController, AuthenticationVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var imageView: UIImageView = {
        $0.image = .authentication
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private lazy var titleLabel: UILabel = {
        $0.text = "Explore the world of films!"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.textAlignment = .center
 
        $0.textColor = .titlePrimary
        return $0
    }(UILabel())
    
    private lazy var descriptionLabel: UILabel = {
        $0.text = "Sign in or create account"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .montserrat(.semiBold, size: FontSize.body)
        $0.textColor = .bodyText
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    

    private lazy var loginButton: UIButton = .styled(
        title: "LOG IN",
        style: .filled,
        target: self,
        action: #selector(loginTapped)
    )
    private lazy var signupButton: UIButton = .styled(
        title: "Create a new account",
        style: .outlined,
        target: self,
        action: #selector(signupTapped)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .buttonPrimary
        view.backgroundColor = .white
        view.addSubviews(
            imageView,
            titleLabel,
            descriptionLabel,
            loginButton,
            signupButton
        )
       
        setupHierarchy()
       
    }
    
    func setupHierarchy() {
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Spacing.xl3
            ),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Size.xl6.width),
            imageView.widthAnchor.constraint(equalToConstant: Size.xl6.height),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Spacing.m),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs4),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs),
            
            loginButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Spacing.xl5),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs),
            
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: Spacing.xs3),
            signupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xs),
            signupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xs)
            
        ])
        
    }
    
    @objc private func loginTapped() {
        (router as? AuthenticationRouterProtocol)?.navigateToLogin()
    }
    
    @objc private func signupTapped() {
        (router as? AuthenticationRouterProtocol)?.navigateToSignUp()
    }
}

