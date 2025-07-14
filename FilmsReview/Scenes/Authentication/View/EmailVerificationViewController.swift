//
//  EmailVerificationViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 14.07.25.
//

import UIKit

protocol EmailVerificationVCProtocol: ViewControllerProtocol {
    
}

final class EmailVerificationViewController: UIViewController, EmailVerificationVCProtocol {
    var interactor: (any InteractorProtocol)?
    
    var router: (any RouterProtocol)?
    private var timer: Timer?
    
    private lazy var titleLabel: UILabel = {
        $0.text = "Email Confirmation"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .buttonPrimary
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var infoLabel: UILabel = {
        $0.text = "We have sent you a confirmation email."
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .titlePrimary
        $0.font = .montserrat(.bold, size: FontSize.title)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var resendLabel: UILabel = {
        $0.text = "Did you not receive the email?"
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .titlePrimary
        $0.font = .montserrat(.medium, size: FontSize.body)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }( UILabel())
    
    private lazy var resendButton: UIButton = .styled(
        title: "Resend",
        style: .outlined,
        target: self,
        action: #selector(resendEmail)
    )
    
    private lazy var exitButton: UIButton = {
        $0.setTitle("Sign Out", for: .normal)
        $0.titleLabel?.font = .montserrat(.bold, size: FontSize.body)
        $0.setTitleColor(.buttonPrimary, for: .normal)
        $0.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubviews(titleLabel, infoLabel, exitButton, resendLabel, resendButton)
        setupConstraints()
        timer = Timer.scheduledTimer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(checkVerification),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs2),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -Spacing.l),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.s),
            
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.l),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            resendButton.bottomAnchor.constraint(equalTo: exitButton.topAnchor, constant: -Spacing.xl),
            resendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s),
            resendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.s),
            resendButton.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            resendLabel.bottomAnchor.constraint(equalTo: resendButton.topAnchor, constant: -Spacing.xs2),
            resendLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
    
    @objc private func checkVerification() {
        (interactor as? AuthenticationInteractorProtocol)?.checkEmailVerified { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(true):
                    self.timer?.invalidate()
                    AppRouter.updateRootViewController()
                case .success(false):
                    break
                case .failure(let error):
                    guard self.view.window != nil else { return }
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func resendEmail() {
        (interactor as? AuthenticationInteractorProtocol)?.resendVerificationEmail { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    let alert = UIAlertController(
                        title: "Email Sent",
                        message: "Please check your inbox again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    
                case .failure(let error):
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signOut() {
        let alert = UIAlertController(
            title: "Confirm Sign Out",
            message: "This will permanently delete your account and sign you out. Continue?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            (self.interactor as? AuthenticationInteractorProtocol)?.deleteAccount { error in
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
