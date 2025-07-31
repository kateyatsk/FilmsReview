//
//  SignUpViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 11.07.25.
//

import UIKit

private enum EditingMode {
    case normal, email, password, confirm
}

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
    
    enum Opacity {
        static let enable: CGFloat = 1.0
        static let disable: CGFloat = 0.5
    }
    
    enum Duration {
        static let switchModeAnimation: CGFloat = 0.25
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

final class SignUpViewController: UIViewController, SignUpVCProtocol, UITextFieldDelegate {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private var validationTopToConfirmConstraint: NSLayoutConstraint!
    private var validationTopToPasswordConstraint: NSLayoutConstraint!
    private var createButtonBottomConstraint: NSLayoutConstraint!
    private var passwordLabelToEmailConstraint: NSLayoutConstraint!
    private var passwordLabelToTitleConstraint: NSLayoutConstraint!
    private var confirmPasswordLabelToPasswordConstraint: NSLayoutConstraint!
    private var confirmPasswordLabelToPasswordLabelConstraint: NSLayoutConstraint!
    
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
        field.addTarget(self, action: #selector(editingBegan(_:)), for: .editingDidBegin)
        return field
    }()
    
    private lazy var passwordLabel = makeLabel(Constants.Text.createPasswordLabel)
    private lazy var passwordField: UITextField = {
        let field = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
        field.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)
        field.addTarget(self, action: #selector(editingBegan(_:)), for: .editingDidBegin)
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
    private lazy var confirmPasswordField: UITextField = {
        let field = makeSecureField(placeholder: Constants.Text.passwordPlaceholder)
        field.addTarget(self, action: #selector(editingBegan(_:)), for: .editingDidBegin)
        return field
    }()
    
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
        setupViewHierarchy()
        layout()
        validationView.reloadTags()
        registerKeyboardNotifications()
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(
            titleLabel, emailLabel, emailField, emailErrorLabel,
            passwordLabel, passwordField,
            validationView,
            confirmPasswordLabel, confirmPasswordField,
            createAccountButton, signInButton
        )
    }
    
    private func layout() {
        validationTopToConfirmConstraint = validationView.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: Spacing.xs3)
        validationTopToPasswordConstraint = validationView.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Spacing.xs3)
        validationTopToPasswordConstraint.isActive = false
        
        createButtonBottomConstraint = createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.xl5)
        
        passwordLabelToEmailConstraint = passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs)
        passwordLabelToTitleConstraint = passwordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs)
        passwordLabelToEmailConstraint.isActive = true
        passwordLabelToTitleConstraint.isActive = false
        
        confirmPasswordLabelToPasswordConstraint = confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Spacing.xs)
        confirmPasswordLabelToPasswordLabelConstraint = confirmPasswordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xs)
        confirmPasswordLabelToPasswordConstraint.isActive = true
        confirmPasswordLabelToPasswordLabelConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xs),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xl),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.m),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: Spacing.xs3),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.m),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.m),
            emailField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            emailErrorLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs5),
            emailErrorLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            emailErrorLabel.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            
            passwordLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            
            passwordLabelToEmailConstraint,
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: Spacing.xs3),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            confirmPasswordLabelToPasswordConstraint,
            
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: Spacing.xs3),
            confirmPasswordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            validationTopToConfirmConstraint,
            validationView.leadingAnchor.constraint(equalTo: confirmPasswordField.leadingAnchor),
            validationView.trailingAnchor.constraint(equalTo: confirmPasswordField.trailingAnchor),
            validationView.heightAnchor.constraint(equalToConstant: Size.xl5.height),
            
            createAccountButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            createAccountButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            createAccountButton.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            createButtonBottomConstraint,
            
            signInButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: Spacing.xs2),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        field.delegate = self
        field.returnKeyType = .next
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
    
    private func switchEditingMode(_ mode: EditingMode) {
        UIView.animate(withDuration: Constants.Duration.switchModeAnimation) {
            [self.passwordLabelToEmailConstraint,
             self.passwordLabelToTitleConstraint,
             self.confirmPasswordLabelToPasswordConstraint,
             self.confirmPasswordLabelToPasswordLabelConstraint,
             self.validationTopToConfirmConstraint,
             self.validationTopToPasswordConstraint
            ].forEach { $0?.isActive = false }
            
            [self.emailLabel,
             self.emailField,
             self.emailErrorLabel,
             self.passwordLabel,
             self.passwordField,
             self.confirmPasswordLabel,
             self.confirmPasswordField,
             self.validationView
            ].forEach { $0.isHidden = true }
            
            switch mode {
            case .normal:
                self.emailLabel.isHidden = false
                self.emailField.isHidden = false
                self.emailErrorLabel.isHidden = false
                self.passwordLabel.isHidden = false
                self.passwordField.isHidden = false
                self.confirmPasswordLabel.isHidden = false
                self.confirmPasswordField.isHidden = false
                self.validationView.isHidden = false
                
                self.passwordLabelToEmailConstraint.isActive = true
                self.confirmPasswordLabelToPasswordConstraint.isActive = true
                self.validationTopToConfirmConstraint.isActive = true
                
            case .email:
                self.emailLabel.isHidden = false
                self.emailField.isHidden = false
                self.emailErrorLabel.isHidden = false
                
            case .password:
                self.passwordLabel.isHidden = false
                self.passwordField.isHidden = false
                self.validationView.isHidden = false
                
                self.passwordLabelToTitleConstraint.isActive = true
                self.validationTopToPasswordConstraint.isActive = true
                
            case .confirm:
                self.confirmPasswordLabel.isHidden = false
                self.confirmPasswordField.isHidden = false
                self.validationView.isHidden = false
                
                self.confirmPasswordLabelToPasswordLabelConstraint.isActive = true
                self.validationTopToConfirmConstraint.isActive = true
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func editingBegan(_ sender: UITextField) {
        if sender == emailField {
            switchEditingMode(.email)
        } else if sender == passwordField {
            switchEditingMode(.password)
        } else if sender == confirmPasswordField {
            switchEditingMode(.confirm)
        }
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
    
    func showEmailVerificationScreen() {
        (router as? AuthenticationRouterProtocol)?.routeToEmailVerification()
    }
    
    private func updateCreateButtonState() {
        let allValid = validationDelegate.rulesState.values.allSatisfy { $0 }
        createAccountButton.isEnabled = allValid
        createAccountButton.alpha = allValid ? Constants.Opacity.enable : Constants.Opacity.disable
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardHeight = view.frame.height - view.convert(keyboardFrame, from: nil).origin.y
        createButtonBottomConstraint.constant = -keyboardHeight - Spacing.xs2
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        createButtonBottomConstraint.constant = -Spacing.xl5
        UIView.animate(withDuration: duration) {
            self.switchEditingMode(.normal)
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            if createAccountButton.isEnabled {
                textField.resignFirstResponder()
                createAccount()
            } else {
                textField.resignFirstResponder()
            }
        }
        return true
    }
}
