//
//  FirebaseAuthManager.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//

import FirebaseAuth

final class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private init() {}
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(error ?? NSError(domain: "Auth", code: -1, userInfo: nil)))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(error ?? NSError(domain: "Auth", code: -1, userInfo: nil)))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
