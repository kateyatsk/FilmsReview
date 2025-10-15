//
//  EmailVerificationViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 14.07.25.
//

import UIKit
import Lottie

fileprivate enum Constants {
    enum Text {
        static let title = "Email Confirmation"
        static let subtitle = "Almost there!"
        static let message = "We’ve sent you an email with a confirmation link. Please open it to continue."
        static let resendLabel = "Did you not receive the email?"
        
        static let resend = "Resend"
        static let signOut = "Sign Out"
        
        static let emailSentTitle = "Email Sent"
        static let emailSentMessage = "Please check your inbox again."
        static let okAction = "OK"
        
        static let confirmSignOutTitle = "Confirm Sign Out"
        static let confirmSignOutMessage = "This will sign you out. Continue?"
        static let cancelAction = "Cancel"
    }
    
    enum Layout {
        static let unlimitedNumberOfLines: Int = 0
    }
}

protocol EmailVerificationVCProtocol: ViewControllerProtocol {
    
}

final class EmailVerificationViewController: UIViewController, EmailVerificationVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var animationView: LottieAnimationView = {
        let anim = LottieAnimation.named("Email")
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
        $0.text = Constants.Text.message
        $0.font = .montserrat(.medium, size: FontSize.body)
        $0.textColor = .titlePrimary
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        return $0
    }(UILabel())
    
    private lazy var subtitleLabel: UILabel = {
        $0.text = Constants.Text.subtitle
        $0.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        $0.textAlignment = .center
        $0.textColor = .titlePrimary
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var resendLabel: UILabel = {
        $0.text = Constants.Text.resendLabel
        $0.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        $0.textAlignment = .center
        $0.textColor = .titlePrimary
        $0.font = .montserrat(.medium, size: FontSize.caption)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var resendButton: UIButton = .styled(
        title: Constants.Text.resend,
        style: .outlined,
        target: self,
        action: #selector(resendEmail)
    )
    
    private lazy var exitButton: UIButton = {
        $0.setTitle(Constants.Text.signOut, for: .normal)
        $0.titleLabel?.font = .montserrat(.bold, size: FontSize.body)
        $0.setTitleColor(.buttonPrimary, for: .normal)
        $0.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        view.addSubviews(
            titleLabel,
            animationView,
            subtitleLabel,
            messageLabel,
            exitButton,
            resendLabel,
            resendButton
        )
        setupConstraints()
        animationView.play()
        resendLabel.isHidden = true
        resendButton.isHidden = true
        (interactor as? AuthenticationInteractorProtocol)?.startEmailVerificationMonitoring()
    }
    
    deinit {
        (interactor as? AuthenticationInteractorProtocol)?.stopEmailVerificationMonitoring()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs2),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.l),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: Size.xl5.width),
            animationView.heightAnchor.constraint(equalToConstant: Size.xl5.height),
            
            subtitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: Spacing.xs),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.s),
            
            messageLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Spacing.xs),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.s),
           
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.l),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resendButton.bottomAnchor.constraint(equalTo: exitButton.topAnchor, constant: -Spacing.xs3),
            resendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s),
            resendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.s),
            resendButton.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            resendLabel.bottomAnchor.constraint(equalTo: resendButton.topAnchor, constant: -Spacing.xs3),
            resendLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
    
    @objc private func resendEmail() {
        (interactor as? AuthenticationInteractorProtocol)?.resendVerificationEmail { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    let alert = UIAlertController(
                        title: Constants.Text.emailSentTitle,
                        message: Constants.Text.emailSentMessage,
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: Constants.Text.okAction, style: .default))
                    self.present(alert, animated: true)
                    
                case .failure(let error):
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signOut() {
        let alert = UIAlertController(
            title: Constants.Text.confirmSignOutTitle,
            message: Constants.Text.confirmSignOutMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.Text.cancelAction, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.Text.signOut, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            (self.interactor as? AuthenticationInteractorProtocol)?.signOut { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showErrorAlert(error.localizedDescription)
                    } else {
                        AppRouter.updateRootViewController()
                    }
                }
            }
        })
        present(alert, animated: true)
    }
    
}
