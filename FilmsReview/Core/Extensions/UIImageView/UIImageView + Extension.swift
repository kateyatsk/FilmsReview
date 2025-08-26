//
//  UIImageView + Extension.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 8.08.25.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil, onError: ((Error) -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.image = placeholder ?? UIImage(systemName: "photo")
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                error == nil,
                let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                let data = data,
                let image = UIImage(data: data)
            else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                let err = NSError(domain: "ImageLoad", code: code,
                                  userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
                DispatchQueue.main.async {
                    self?.image = UIImage(systemName: "exclamationmark.triangle")
                    onError?(err)
                }
                return
            }
            
            DispatchQueue.main.async { self?.image = image }
        }.resume()
    }
}
