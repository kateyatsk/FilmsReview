//
//  MovieListViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 24.06.25.
//

import UIKit
import FirebaseAuth

protocol MovieListVCProtocol: ViewControllerProtocol {
    func requestDataReload()
    func updateMoviesTable()
}

final class MovieListViewController: UIViewController, MovieListVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Interactor is: \(String(describing: interactor))") // Debug
        setupHierarchy()
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
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20), // Offset above button
                        
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20), // Place below label

            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func updateMoviesTable() {
        try? Auth.auth().signOut()
        print("Table updated")
        AppRouter.updateRootViewController()
    }
}


