//
//
//  ProfileViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol ProfileViewProtocol: ViewControllerProtocol {
    func displayLoading(_ isLoading: Bool)
    func displayProfile(_ vm: Profile.Load.ViewModel)
    func displayError(_ message: String)
    func displayLoggedOut()
}

fileprivate enum Constants {
    enum Text {
        static let name = "Name"
        static let email = "Email"
        static let genres = "Favorite Genres"
        static let birthday = "Birthday"
        static let signOut = "Sign Out"
        static let error = "Error"
        static let ok = "OK"
        static let signOutConfirmTitle = "Sign Out?"
        static let signOutConfirmMessage = "Are you sure you want to sign out?"
        static let cancel = "Cancel"
        static let confirmSignOut = "Sign Out"
    }
    enum Layout {
        static let cardMinHeight: CGFloat = 56
        static let rowSpacing: CGFloat = 12
        static let buttonMinHeight: CGFloat = 46
        static let avatarBorderWidth: CGFloat = 1
        static let cardBorderWidth: CGFloat = 1
    }
    enum Icon {
        static let person = "person"
        static let envelope = "envelope"
        static let tag = "tag"
        static let calendar = "calendar"
    }
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {

    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let avatarImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = .systemGray5
        v.layer.borderWidth = Constants.Layout.avatarBorderWidth
        v.layer.borderColor = UIColor.systemGray4.cgColor
        return v
    }()

    private let signOutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(Constants.Text.signOut, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemRed
        b.layer.cornerRadius = CornerRadius.xl2
        b.titleLabel?.font = .montserrat(.semiBold, size: FontSize.body)
        b.contentEdgeInsets = .init(top: Spacing.xs4, left: Spacing.xs3, bottom: Spacing.xs4, right: Spacing.xs3)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
        bindActions()
        if let placeholder = UIImage(resource: .noAvatar) as UIImage? {
            avatarImageView.image = placeholder
        }
        (interactor as? ProfileInteractorProtocol)?.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = Size.xl4.width / 2
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .montserrat(.semiBold, size: FontSize.body)
        l.textColor = .label
        return l
    }

    private func makeInfoCard(icon systemName: String) -> (container: UIView, valueLabel: UILabel) {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = CornerRadius.m
        container.layer.borderWidth = Constants.Layout.cardBorderWidth
        container.layer.borderColor = UIColor.quaternaryLabel.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: systemName))
        iconView.tintColor = .secondaryLabel
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.numberOfLines = 0
        valueLabel.font = .montserrat(.regular, size: FontSize.body)
        valueLabel.textColor = .titlePrimary

        let row = UIStackView(arrangedSubviews: [iconView, valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = Constants.Layout.rowSpacing
        row.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(row)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Layout.cardMinHeight),
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: Spacing.xs4),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Spacing.xs4),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Spacing.xs3),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Spacing.xs3),
            iconView.widthAnchor.constraint(equalToConstant: Size.m.width),
            iconView.heightAnchor.constraint(equalToConstant: Size.m.height)
        ])
        return (container, valueLabel)
    }

    private lazy var nameSectionTitle = makeSectionTitle(Constants.Text.name)
    private lazy var nameCard = makeInfoCard(icon: Constants.Icon.person)

    private lazy var emailSectionTitle = makeSectionTitle(Constants.Text.email)
    private lazy var emailCard = makeInfoCard(icon: Constants.Icon.envelope)

    private lazy var genresSectionTitle = makeSectionTitle(Constants.Text.genres)
    private lazy var genresCard = makeInfoCard(icon: Constants.Icon.tag)

    private lazy var birthdaySectionTitle = makeSectionTitle(Constants.Text.birthday)
    private lazy var birthdayCard = makeInfoCard(icon: Constants.Icon.calendar)

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = Spacing.xs3
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(signOutButton)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -Spacing.xs5),

            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.m),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.m),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.xs5),
            signOutButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Layout.buttonMinHeight),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Spacing.xs3),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.xs2),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.xs2),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Spacing.xs3)
        ])

        let avatarContainer = UIView()
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(avatarImageView)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Size.xl4.width),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor)
        ])

        contentStack.addArrangedSubview(avatarContainer)
        contentStack.addArrangedSubview(nameSectionTitle)
        contentStack.addArrangedSubview(nameCard.container)
        contentStack.addArrangedSubview(emailSectionTitle)
        contentStack.addArrangedSubview(emailCard.container)
        contentStack.addArrangedSubview(genresSectionTitle)
        contentStack.addArrangedSubview(genresCard.container)
        contentStack.addArrangedSubview(birthdaySectionTitle)
        contentStack.addArrangedSubview(birthdayCard.container)

        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindActions() {
        signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
    }

    func displayLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        signOutButton.isEnabled = !isLoading
        signOutButton.alpha = isLoading ? 0.6 : 1.0
    }

    func displayProfile(_ vm: Profile.Load.ViewModel) {
        nameCard.valueLabel.text = vm.nameValue
        emailCard.valueLabel.text = vm.emailValue
        genresCard.valueLabel.text = vm.genresValue
        birthdayCard.valueLabel.text = vm.birthdayValue
        avatarImageView.image = vm.avatar ?? UIImage(resource: .noAvatar)
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: Constants.Text.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Text.ok, style: .default))
        present(alert, animated: true)
    }

    func displayLoggedOut() {
        (router as? ProfileRouterProtocol)?.routeToAuth()
    }

    @objc private func handleSignOut() {
        let alert = UIAlertController(
            title: Constants.Text.signOutConfirmTitle,
            message: Constants.Text.signOutConfirmMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.Text.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.Text.confirmSignOut, style: .destructive) { [weak self] _ in
            (self?.interactor as? ProfileInteractorProtocol)?.logout()
        })
        present(alert, animated: true)
    }

}
