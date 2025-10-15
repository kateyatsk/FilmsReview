//
//  CheckEmailViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 29.07.25.
//

import UIKit
import Lottie

fileprivate enum Constants {
    enum Text {
        static let title = "Forgot password"
        static let emailPlaceholder = "Email"
        static let message = "If this email exists, we sent you a password reset link to %@.\n\nPlease check your inbox."
        static let backButtonTitle = "Back to Login"
    }
    
    enum Layout {
        static let unlimitedNumberOfLines: Int = 0
    }
}

protocol CheckEmailVCProtocol: ViewControllerProtocol {
    
}

final class CheckEmailViewController: UIViewController, CheckEmailVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    var email: String = ""
    
    private lazy var animationView: LottieAnimationView = {
        let anim = LottieAnimation.named(Constants.Text.emailPlaceholder)
        let view = LottieAnimationView(animation: anim)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        return view
    }()

    private lazy var titleLabel: UILabel = {
        $0.text = Constants.Text.title
        $0.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        $0.textAlignment = .center
        $0.textColor = .buttonPrimary
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = String(format: Constants.Text.message, email)
        label.font = .montserrat(.semiBold, size: FontSize.body)
        label.textColor = .titlePrimary
        label.textAlignment = .center
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backButton: UIButton = .styled(
        title: Constants.Text.backButtonTitle,
        style: .filled,
        target: self,
        action: #selector(navigateToLoginScreen)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubviews(messageLabel, titleLabel, animationView, backButton)
        navigationItem.setHidesBackButton(true, animated: false)
        hideKeyboardWhenTappedAround()
        setupConstraints()
        animationView.play()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs2),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.l),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: Size.xl5.width),
            animationView.heightAnchor.constraint(equalToConstant: Size.xl5.height),
            
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.m),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.m),
            
            backButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Spacing.xl),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            
        ])
    }
    
    @objc func navigateToLoginScreen() {
        (self.router as? AuthenticationRouterProtocol)?.navigateToLogin()
    }
}
