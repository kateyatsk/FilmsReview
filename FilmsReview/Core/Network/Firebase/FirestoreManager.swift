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
}
