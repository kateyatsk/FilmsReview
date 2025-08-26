//
//  CreateProfileViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 31.07.25.
//

import Foundation
import UIKit

fileprivate enum Constants {
    enum Text {
        static let profileName = "Profile Name"
        static let birthday = "Birthday"
        static let namePlaceholder = "Enter name"
        static let birthdayPlaceholder = "MM/DD/YYYY"
        static let createProfile = "Create Profile"
        static let datePickerDone = "Done"
    }
    
    enum Layout {
        static let border: CGFloat = 3
    }
    
    enum Age {
        static let minYears = 6
        static let maxYears = 100
    }
}

protocol CreateProfileVC: ViewControllerProtocol {}

final class CreateProfileViewController: UIViewController, CreateProfileVC {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.createProfile
        label.font = .montserrat(.semiBold, size: FontSize.title)
        label.textColor = .titlePrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .systemGray3
        iv.layer.cornerRadius = Size.xl4.width / 2
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var editAvatarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "pencil.circle"))
        iv.tintColor = .white
        iv.backgroundColor = .titlePrimary
        iv.layer.cornerRadius = Size.xl.width / 2
        iv.layer.borderWidth = Constants.Layout.border
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.profileName
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = Constants.Text.namePlaceholder
        tf.borderStyle = .none
        tf.layer.cornerRadius = CornerRadius.xl2
        tf.layer.borderColor = UIColor.systemGray3.cgColor
        tf.layer.borderWidth = Spacing.xs6
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.xs, height: Size.xl2.height))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.xs, height: Size.xl2.height))
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.birthday
        label.font = .montserrat(.regular, size: FontSize.caption)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var birthdayTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = Constants.Text.birthdayPlaceholder
        tf.borderStyle = .none
        tf.layer.cornerRadius = CornerRadius.xl2
        tf.layer.borderColor = UIColor.systemGray3.cgColor
        tf.layer.borderWidth = Spacing.xs6
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.xs, height: Size.xl2.height))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.xs, height: Size.xl2.height))
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var birthdayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        
        let now = Date()
        let cal = Calendar.current
        if let maxDate = cal.date(byAdding: .year, value: -Constants.Age.minYears, to: now),
           let minDate = cal.date(byAdding: .year, value: -Constants.Age.maxYears, to: now) {
            picker.maximumDate = maxDate
            picker.minimumDate = minDate
        }
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var createButton: UIButton = .styled(
        title: Constants.Text.createProfile,
        style: .filled,
        target: self,
        action: #selector(navigateToHome)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        hideKeyboardWhenTappedAround()
        configureDatePicker()
        addAvatarTap()
    }
    
    private func configureDatePicker() {
        birthdayTextField.inputView = birthdayPicker
        
        let toolbar = UIToolbar(frame: CGRect(x: .zero, y: .zero, width: view.frame.width, height: Spacing.xl3))
        let doneButton = UIBarButtonItem(title: Constants.Text.datePickerDone, style: .plain, target: self, action: #selector(donePickingDate))
        toolbar.setItems([doneButton], animated: false)
        
        birthdayTextField.inputAccessoryView = toolbar
    }
    
    @objc private func donePickingDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        birthdayTextField.text = formatter.string(from: birthdayPicker.date)
        birthdayTextField.resignFirstResponder()
    }
    
    private func setupUI() {
        view.addSubviews(
            titleLabel,
            avatarImageView,
            editAvatarIcon,
            nameLabel,
            nameTextField,
            birthdayLabel,
            birthdayTextField,
            createButton
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.l),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.m),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Size.xl4.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Size.xl4.height),
            
            editAvatarIcon.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            editAvatarIcon.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            editAvatarIcon.widthAnchor.constraint(equalToConstant: Size.xl.width),
            editAvatarIcon.heightAnchor.constraint(equalToConstant: Size.xl.height),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Spacing.xl2),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Spacing.xs4),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            nameTextField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            birthdayLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Spacing.m),
            birthdayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            
            birthdayTextField.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: Spacing.xs4),
            birthdayTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            birthdayTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            birthdayTextField.heightAnchor.constraint(equalToConstant: Size.xl2.height),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl),
            createButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.m)
        ])
    }
    
    private func addAvatarTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func editAvatarTapped() {
        presentImagePicker()
    }
    
    @objc private func navigateToHome() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            showErrorAlert("Name cannot be empty")
            return
        }
        let birthday = birthdayPicker.date
        let avatarData = avatarImageView.image?
            .jpegData(compressionQuality: 0.8)
        
        (interactor as? AuthenticationInteractorProtocol)?
            .createProfile(name: name, birthday: birthday, avatarData: avatarData)
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
}

extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let editedImage = info[.editedImage] as? UIImage {
            avatarImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            avatarImageView.image = originalImage
        }
    }
}
