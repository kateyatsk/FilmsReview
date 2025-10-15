//
//  ForgotPasswordViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 28.07.25.
//

import UIKit

fileprivate enum Constants {
    enum Text {
        static let forgotPasswordInTitle = "Forgot password"
        static let emailPlaceholder = "Email"
        static let continueButton = "Continue"
        static let helpMessage = "Input your linked email to your account below, we’ll send you a link"
        static let emailAlert = "Enter your email"
    }
    
    enum Layout {
        static let unlimitedNumberOfLines: Int = 0
    }
}

protocol ForgotPasswordVCProtocol: ViewControllerProtocol {
    func showCheckYourEmailScreen()
}

final class ForgotPasswordViewController: UIViewController, ForgotPasswordVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var continueButton: UIButton = .styled(
        title: Constants.Text.continueButton,
        style: .filled,
        target: self,
        action: #selector(continueTapped)
    )
    
    private lazy var titleLabel: UILabel = {
        $0.text = Constants.Text.forgotPasswordInTitle
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.textAlignment = .center
        $0.textColor = .buttonPrimary
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.helpMessage
        label.font = .montserrat(.semiBold, size: FontSize.caption)
        label.textColor = .titlePrimary
        label.textAlignment = .center
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.setPlaceholder(Constants.Text.emailPlaceholder, color: .titlePrimary)
        textField.layer.borderWidth = Spacing.xs6
        textField.layer.cornerRadius = CornerRadius.xl
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubviews(titleLabel, emailField, continueButton, messageLabel)
        layout()
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xl5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs3),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            
            emailField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Spacing.l),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            emailField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            continueButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xl),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            continueButton.heightAnchor.constraint(equalToConstant: Size.xl2.height)
        ])
    }
    
    @objc func continueTapped() {
        guard let email = emailField.text, !email.isEmpty else {
            showErrorAlert(Constants.Text.emailAlert)
            return
        }
        (interactor as? AuthenticationInteractorProtocol)?.resetPassword(email: email)
    }
    
    func showCheckYourEmailScreen() {
        (router as? AuthenticationRouterProtocol)?.navigateToCheckYourEmail(email: emailField.text ?? "")
    }
}
