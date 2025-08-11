//
//  UIImageView + Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 8.08.25.
//

import UIKit
extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let self = self,
                let data = data,
                let image = UIImage(data: data),
                error == nil
            else {
                print("Error loading image:", error ?? "Unknown error")
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
