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
        static let emailErrorMessage = "Please enter a valid email address."
        
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
        
    }
    
    enum Layout {
        static let unlimitedNumberOfLines: Int = 0
    }
    
    enum Size {
        static let validationViewHeight: CGFloat = 80
    }
    
    enum Opacity {
        static let enable: CGFloat = 1.0
        static let disable: CGFloat = 0.5
    }
    
    enum ValidationMessages {
        static let minLength = "6+ characters"
        static let hasLowercase = "1+ lowercase"
        static let hasUppercase = "1+ uppercase"
        static let noWhitespaces = "No whitespaces"
        static let hasDigit = "1+ digit"
        static let onlyLatin = "Only Latin letters"
        static let hasSpecialChar = "1+ special char"
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
    private lazy var emailField: UITextField = {
        let field = makeTextField(placeholder: Constants.Text.emailPlaceholder)
        field.addTarget(self, action: #selector(emailChanged(_:)), for: .editingChanged)
        return field
    }()
    
    private lazy var passwordLabel = makeLabel(Constants.Text.createPasswordLabel)
    private lazy var passwordField: UITextField = {
        let field = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
        field.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)
        return field
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.numberOfLines = Constants.Layout.unlimitedNumberOfLines
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordLabel = makeLabel(Constants.Text.confirmPasswordLabel)
    private lazy var confirmPasswordField = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton.styled(
            title: Constants.Text.signUp,
            style: .filled,
            target: self,
            action: #selector(createAccount)
        )
        button.isEnabled = false
        button.alpha = Constants.Opacity.disable
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Text.haveAccountMessage, for: .normal)
        button.setTitleColor(.buttonPrimary, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var validationDelegate: ValidationDelegate = {
        let rules: [ValidationRule] = [
            ValidationRule(message: Constants.ValidationMessages.noWhitespaces, regex: ValidationRegex.noWhitespaces.rawValue),
            ValidationRule(message: Constants.ValidationMessages.hasDigit, regex: ValidationRegex.hasDigit.rawValue),
            ValidationRule(message: Constants.ValidationMessages.onlyLatin, regex: ValidationRegex.onlyLatin.rawValue),
            ValidationRule(message: Constants.ValidationMessages.minLength, regex: ValidationRegex.minLength.rawValue),
            ValidationRule(message: Constants.ValidationMessages.hasLowercase, regex: ValidationRegex.hasLowercase.rawValue),
            ValidationRule(message: Constants.ValidationMessages.hasUppercase, regex: ValidationRegex.hasUppercase.rawValue),
            ValidationRule(message: Constants.ValidationMessages.hasSpecialChar, regex: ValidationRegex.hasSpecialChar.rawValue)
        ]
        return ValidationDelegate(rules: rules)
    }()
    
    private lazy var validationView: ValidationTagContainerView = {
        let view = ValidationTagContainerView(delegate: validationDelegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        hideKeyboardWhenTappedAround()
        
        view.addSubviews(
            titleLabel,
            emailLabel, emailField, emailErrorLabel,
            passwordLabel, passwordField,
            validationView,
            confirmPasswordLabel, confirmPasswordField,
            createAccountButton,
            signInButton
        )
        
        layout()
        validationView.reloadTags()
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xl5),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: Spacing.xs3),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            emailField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            emailErrorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs5),
            emailErrorLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            emailErrorLabel.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: Spacing.xs3),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Spacing.xs2),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: Spacing.xs3),
            confirmPasswordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            validationView.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: Spacing.xs3),
            validationView.leadingAnchor.constraint(equalTo: confirmPasswordField.leadingAnchor),
            validationView.trailingAnchor.constraint(equalTo: confirmPasswordField.trailingAnchor),
            validationView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Size.validationViewHeight),
            
            createAccountButton.topAnchor.constraint(equalTo: validationView.bottomAnchor, constant: Spacing.l),
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
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: .zero)))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: .zero)))
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
    
    @objc private func emailChanged(_ sender: UITextField) {
        guard let interactor = interactor as? AuthenticationInteractorProtocol else { return }
        let email = sender.text ?? ""
        let isValid = interactor.validateEmail(email)
        emailField.layer.borderColor = isValid ? UIColor.titlePrimary.cgColor : UIColor.systemRed.cgColor
        emailErrorLabel.isHidden = isValid
        emailErrorLabel.text = isValid ? "" : Constants.Text.emailErrorMessage
    }
    
    @objc private func passwordChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        validationDelegate.checkValidationTags(text: text) {
            validationView.reloadTags()
            updateCreateButtonState()
        }
    }
    
    private func updateCreateButtonState() {
        let allValid = validationDelegate.rulesState.values.allSatisfy { $0 }
        createAccountButton.isEnabled = allValid
        createAccountButton.alpha = allValid ? Constants.Opacity.enable : Constants.Opacity.disable
    }
    
}
