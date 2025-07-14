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
    
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func isEmailVerified() -> Bool {
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }
    
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "Auth", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }
        user.sendEmailVerification(completion: completion)
    }
    
    func reloadUser(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "Auth", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }
        user.reload(completion: completion)
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No logged-in user"]
            ))
            return
        }
        user.delete { error in
            completion(error)
        }
    }
}
