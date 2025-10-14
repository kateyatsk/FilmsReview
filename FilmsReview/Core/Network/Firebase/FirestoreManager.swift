//
//  FirestoreManager.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 2.08.25.
//

import Foundation
import FirebaseFirestore

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func setDocument(
        at path: String,
        data: [String: Any],
        merge: Bool = false,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.document(path).setData(data, merge: merge) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getDocument(
        at path: String,
        completion: @escaping (Result<[String:Any], Error>) -> Void
    ) {
        db.document(path).getDocument { snap, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = snap?.data() {
                completion(.success(data))
            } else {
                completion(.success([:]))
            }
        }
    }
    
    func deleteDocument(
        at path: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.document(path).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getDocumentAsync(at path: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            getDocument(at: path) { result in
                switch result {
                case .success(let data): continuation.resume(returning: data)
                case .failure: continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func fetchUserProfile(uid: String) async -> UserProfile? {
        guard !uid.isEmpty,
              let data = await getDocumentAsync(at: "users/\(uid)") else { return nil }
        
        let birthday: Date = {
            if let ts = data["birthday"] as? Timestamp { return ts.dateValue() }
            if let t  = data["birthday"] as? TimeInterval { return Date(timeIntervalSince1970: t) }
            return Date(timeIntervalSince1970: 0)
        }()
        
        let email = (data["email"] as? String) ?? ""
        let name = (data["name"]  as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let favoriteGenres = data["favoriteGenres"] as? [String]
        
        let avatarURL: URL? = {
            if let s = data["avatarURL"] as? String { return URL(string: s) }
            if let s = data["avatarUrl"] as? String { return URL(string: s) }
            return nil
        }()
        
        return UserProfile(
            uid: uid,
            email: email,
            name: name,
            birthday: birthday,
            avatarURL: avatarURL,
            favoriteGenres: favoriteGenres
        )
    }
    
}
