//
//  SignUpViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 11.07.25.
//

import UIKit

fileprivate enum Constants {
    enum Text {
        static let signUpTitle = "Sign Up"
        static let signUp = "Create a new account"
        
        static let enterEmailLabel = "Enter your email address:"
        static let createPasswordLabel = "Create a password:"
        static let confirmPasswordLabel = "Confirm your password:"
        
        static let haveAccountMessage = "Do you already have an account?"
        static let passwordsDoNotMatch = "Passwords do not match."
        static let allFieldsRequired = "All fields are required."
        
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
        
    }
}


protocol SignUpVCProtocol: ViewControllerProtocol {
    func showEmailVerificationScreen()
}

final class SignUpViewController: UIViewController, SignUpVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.signUpTitle
        label.font = .montserrat(.extraBold, size: FontSize.title)
        label.textAlignment = .center
        label.textColor = .buttonPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel = makeLabel(Constants.Text.enterEmailLabel)
    private lazy var emailField = makeTextField(placeholder: Constants.Text.emailPlaceholder)
    
    private lazy var passwordLabel = makeLabel(Constants.Text.createPasswordLabel)
    private lazy var passwordField = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
    
    private lazy var confirmPasswordLabel = makeLabel(Constants.Text.confirmPasswordLabel)
    private lazy var confirmPasswordField = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
    
    private lazy var createAccountButton: UIButton = .styled(
        title: Constants.Text.signUp,
        style: .filled,
        target: self,
        action: #selector(createAccount)
    )
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Text.haveAccountMessage, for: .normal)
        button.setTitleColor(.buttonPrimary, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubviews(
            titleLabel,
            emailLabel, emailField,
            passwordLabel, passwordField,
            confirmPasswordLabel, confirmPasswordField,
            createAccountButton,
            signInButton
        )
        
        layout()
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xl5),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xl5),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: Spacing.xs3),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            emailField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: Spacing.xs3),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Spacing.xs),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: Spacing.xs3),
            confirmPasswordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: Spacing.l),
            createAccountButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            createAccountButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            createAccountButton.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: Spacing.xs2),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func showEmailVerificationScreen() {
        (router as? AuthenticationRouterProtocol)?.routeToEmailVerification()
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .montserrat(.semiBold, size: FontSize.body)
        label.textColor = .titlePrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        configureTextField(field, placeholder: placeholder)
        return field
    }
    
    private func makeSecureField(placeholder: String) -> UITextField {
        let field = makeTextField(placeholder: placeholder)
        field.isSecureTextEntry = true
        
        return field
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.setPlaceholder(placeholder, color: .titlePrimary)
        textField.layer.borderWidth = Spacing.xs6
        textField.layer.cornerRadius = CornerRadius.xl
        textField.layer.borderColor = UIColor.titlePrimary.cgColor
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func createAccount() {
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm = confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !email.isEmpty, !password.isEmpty, !confirm.isEmpty else {
            showErrorAlert(Constants.Text.allFieldsRequired)
            return
        }
        
        if password != confirm {
            showErrorAlert(Constants.Text.passwordsDoNotMatch)
            return
        }
    
        (interactor as? AuthenticationInteractorProtocol)?.register(email: email, password: password)
    }
    
    @objc private func loginTapped() {
        (router as? AuthenticationRouterProtocol)?.navigateToLogin()
    }
}
