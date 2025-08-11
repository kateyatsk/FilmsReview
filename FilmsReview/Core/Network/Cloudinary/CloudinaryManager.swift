//
//  CloudinaryManager.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 5.08.25.
//

import Cloudinary
import UIKit

protocol CloudinaryManaging {
  func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void)
}

class CloudinaryManager: CloudinaryManaging {
    let cloudName: String = "dttf8bz2q"
    var uploadPreset: String = "default"
    var cloudinary: CLDCloudinary!
    
    init() {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }
    
    func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(
                NSError(domain: "CloudinaryManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            ))
            return
        }
        cloudinary.createUploader()
            .upload(data: jpegData, uploadPreset: "default", completionHandler:  { response, error in
                DispatchQueue.main.async {
                    if let urlString = response?.secureUrl,
                       let url = URL(string: urlString) {
                        completion(.success(url))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(
                            NSError(domain: "CloudinaryManager",
                                    code: -2,
                                    userInfo: [NSLocalizedDescriptionKey: "Unknown upload error"])
                        ))
                    }
                }
            })
    }
}
