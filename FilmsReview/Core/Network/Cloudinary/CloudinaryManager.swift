//
//  CloudinaryManager.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 5.08.25.
//

import Cloudinary
import UIKit

fileprivate enum CloudinaryConstants {
    static let cloudName = "dttf8bz2q"
    static let uploadPreset = "default"
    static let jpegQuality: CGFloat = 0.8
}

fileprivate enum CloudinaryError: Int, LocalizedError, CustomNSError {
    case invalidImageData = -1
    case unknownUploadError = -2
    
    static var errorDomain: String { "CloudinaryManager" }
    var errorCode: Int { rawValue }
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: errorDescription ?? ""]
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:  return "Invalid image data"
        case .unknownUploadError:return "Unknown upload error"
        }
    }
}

protocol CloudinaryManaging {
    func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void)
}

final class CloudinaryManager: CloudinaryManaging {
    private let uploadPreset: String = CloudinaryConstants.uploadPreset
    private let cloudinary: CLDCloudinary
    
    init() {
        let config = CLDConfiguration(cloudName: CloudinaryConstants.cloudName, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }
    
    func upload(data: Data, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: CloudinaryConstants.jpegQuality) else {
            completion(.failure(CloudinaryError.invalidImageData))
            return
        }
        cloudinary.createUploader()
            .upload(data: jpegData, uploadPreset: uploadPreset, completionHandler:  { response, error in
                DispatchQueue.main.async {
                    if let urlString = response?.secureUrl,
                       let url = URL(string: urlString) {
                        completion(.success(url))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(CloudinaryError.unknownUploadError))
                    }
                }
            })
    }
}
