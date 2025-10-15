//
//  LoginViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 11.07.25.
//

import Foundation
import UIKit

fileprivate enum Constants {
    enum Text {
        static let signInTitle = "Sign In"
        static let noAccountMessage = "Don't you have an account yet?"
        static let forgotPasswordMessage = "Forgot password?"
        static let logIn = "LOG IN"
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
        static let allFieldsRequired = "All fields are required."
    }
}

protocol LoginVCProtocol: ViewControllerProtocol {
    func showEmailVerificationScreen()
}

final class LoginViewController: UIViewController,LoginVCProtocol, UITextFieldDelegate {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private var isSubmitting = false
    
    private lazy var titleLabel: UILabel = {
        $0.text = Constants.Text.signInTitle
        $0.font = .montserrat(.extraBold, size: FontSize.title)
        $0.textAlignment = .center
        $0.textColor = .buttonPrimary
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var emailField: UITextField = setupEmailField()
    private lazy var passwordField: UITextField = setupPasswordField()
    
    private lazy var loginButton: UIButton = .styled(
        title: Constants.Text.logIn,
        style: .filled,
        target: self,
        action: #selector(signInTapped)
    )
    
    private lazy var signUpButton: UIButton = {
        $0.setTitle(Constants.Text.noAccountMessage, for: .normal)
        $0.setTitleColor(.buttonPrimary, for: .normal)
        $0.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return $0
    }(UIButton())
    
    private lazy var forgotPasswordButton: UIButton = {
        $0.setTitle(Constants.Text.forgotPasswordMessage, for: .normal)
        $0.setTitleColor(.titlePrimary, for: .normal)
        $0.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(showForgotPasswordScreen), for: .touchUpInside)
        return $0
    }(UIButton())
    
    private lazy var togglePasswordButton: UIButton = {
        $0.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        $0.tintColor = .darkGray
        $0.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return $0
    }(UIButton())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        hideKeyboardWhenTappedAround()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubviews(
            titleLabel,
            emailField,
            passwordField,
            loginButton,
            signUpButton,
            forgotPasswordButton
        )
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.xl5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            
            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.xl5),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            emailField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Spacing.xs),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            passwordField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: Spacing.l),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            loginButton.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: Spacing.xs2),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Spacing.xs5),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor)
        ])
    }
    
    private func setupEmailField() -> UITextField {
        let emailField = UITextField()
        configureTextField(emailField, placeholder: Constants.Text.emailPlaceholder)
        return emailField
    }
    
    private func setupPasswordField() -> UITextField {
        let passwordField = UITextField()
        configureTextField(passwordField, placeholder: Constants.Text.passwordPlaceholder)
        passwordField.isSecureTextEntry = true
        
        let container = UIView(frame: CGRect(origin: .zero, size: Size.xl))
        togglePasswordButton.frame = CGRect(origin: .zero, size: Size.l)
        togglePasswordButton.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        container.addSubview(togglePasswordButton)
        
        passwordField.rightView = container
        passwordField.rightViewMode = .always
        
        return passwordField
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.setPlaceholder(placeholder, color: .titlePrimary)
        textField.layer.borderWidth = Spacing.xs6
        textField.layer.cornerRadius = CornerRadius.xl
        textField.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Spacing.xs2, height: 0)))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func showEmailVerificationScreen() {
        (router as? AuthenticationRouterProtocol)?.routeToEmailVerification()
    }
    
    @objc private func showForgotPasswordScreen() {
        (router as? AuthenticationRouterProtocol)?.navigateToForgotPassword()
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func signUpTapped() {
        (router as? AuthenticationRouterProtocol)?.navigateToSignUp()
    }
    
    @objc private func signInTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        loginButton.isEnabled = false
        
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !email.isEmpty,!password.isEmpty else {
            showErrorAlert(Constants.Text.allFieldsRequired)
            finishSubmitting()
            return
        }
        
        (interactor as? AuthenticationInteractorProtocol)?.login(email: email, password: password)
    }
    
    func finishSubmitting() {
        isSubmitting = false
        loginButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            signInTapped()
        }
        return true
    }
    
}
