//
//  
//  ProfileViewController.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol ProfileVCProtocol: ViewControllerProtocol {}

final class ProfileViewController: UIViewController, ProfileVCProtocol {
    var interactor: (any InteractorProtocol)?
    var router: (any RouterProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
