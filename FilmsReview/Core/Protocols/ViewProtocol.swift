//
//  ViewProtocol.swift
//  FilmsReview
//
//  Created by Alex Mialeshka on 25/06/2025.
//

import UIKit

protocol ViewControllerProtocol: UIViewController {
    var interactor: InteractorProtocol? { get set }
    var router: RouterProtocol? { get set }
}
