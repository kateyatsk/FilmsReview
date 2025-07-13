//
//  UIViewController+Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 14.07.25.
//

import Foundation

extension UIViewController {
    func showErrorAlert(_ message: String, title: String = "Error") {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
