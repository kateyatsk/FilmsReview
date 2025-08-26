//
//  MovieListViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol MovieListVCProtocol: ViewControllerProtocol {
    func requestDataReload()
    func updateMoviesTable()
}

fileprivate enum Constants {
    enum Text {
        static let hello = "Hello, World!"
        static let updateButton = "Update Movies"
    }
    enum Size {
        static let avatarBorder: CGFloat = 1
        static let buttonWidth: CGFloat = 200
        static let buttonHeight: CGFloat = 50
    }
}

final class MovieListViewController: UIViewController, MovieListVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var cloudinaryImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = Spacing.xl4
        iv.layer.masksToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.borderWidth = Constants.Size.avatarBorder
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cloudinaryImageView)
        setupHierarchy()
        loadCloudinaryImage()
    }
    
    @objc func requestDataReload() {
        if let interactor = interactor as? MovieListInteractor {
            interactor.sendFetchRequestToAPI()
        }
    }
    
    func setupHierarchy() {
        
        let label = UILabel()
        label.text = Constants.Text.hello
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBlue
        
        let button = UIButton(type: .system)
        button.setTitle(Constants.Text.updateButton, for: .normal)
        button.layer.cornerRadius = CornerRadius.s
        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(requestDataReload), for: .touchUpInside)
        view.addSubview(button)
        
        view.addSubview(label)
        view.backgroundColor = .lightGray
        
        NSLayoutConstraint.activate([
            cloudinaryImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cloudinaryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloudinaryImageView.widthAnchor.constraint(equalToConstant: Size.xl4.width),
            cloudinaryImageView.heightAnchor.constraint(equalToConstant: Size.xl4.height),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -Size.s.width),
                        
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Spacing.xs2),

            button.widthAnchor.constraint(equalToConstant: Constants.Size.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: Constants.Size.buttonHeight)
        ])
    }
    
    func updateMoviesTable() {
        try? Auth.auth().signOut()
        AppSettings.isAuthorized = false
        AppRouter.updateRootViewController()
    }
    
    private func loadCloudinaryImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userDocRef = Firestore.firestore().collection("users").document(uid)
        
        userDocRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard
                let data = snapshot?.data(),
                let avatarURLString = data["avatarURL"] as? String,
                let avatarURL = URL(string: avatarURLString)
            else {
                print("avatarURL is missing or invalid in Firestore")
                return
            }

            self.cloudinaryImageView.loadImage(from: avatarURL)
        }
    }
}


