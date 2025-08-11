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

final class MovieListViewController: UIViewController, MovieListVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    private lazy var cloudinaryImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 48
        iv.layer.masksToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cloudinaryImageView)
        print("Interactor is: \(String(describing: interactor))") 
        setupHierarchy()
        loadCloudinaryImage()
    }
    
    @objc func requestDataReload() {
        print("VC sends action to interactor for movies update")
        if let interactor = interactor as? MovieListInteractor {
            interactor.sendFetchRequestToAPI()
        }
    }
    
    func setupHierarchy() {
        
        let label = UILabel()
        label.text = "Hello, World!"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBlue
        
        let button = UIButton(type: .system)
        button.setTitle("Update Movies", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(requestDataReload), for: .touchUpInside)
        view.addSubview(button)
        
        
        view.addSubview(label)
        view.backgroundColor = .lightGray
        
        NSLayoutConstraint.activate([
            cloudinaryImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cloudinaryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloudinaryImageView.widthAnchor.constraint(equalToConstant: 96),
            cloudinaryImageView.heightAnchor.constraint(equalToConstant: 96),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                        
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),

            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func updateMoviesTable() {
        try? Auth.auth().signOut()
        print("Table updated")
        AppSettings.isAuthorized = false
        AppRouter.updateRootViewController()
    }
    
    private func loadCloudinaryImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
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


