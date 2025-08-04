//
//
//  AuthenticationWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.07.25.
//
//

import FirebaseAuth

typealias User = FirebaseAuth.User

protocol AuthenticationWorkerProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signOut(completion: @escaping (Error?) -> Void)
    
    func isUserLoggedIn() -> Bool
    func isEmailVerified() -> Bool
    func sendVerificationEmail(completion: @escaping (Error?) -> Void)
    func reloadUser(completion: @escaping (Error?) -> Void)
    func resetPassword(email: String, completion: @escaping (Error?) -> Void)
    func saveUserProfile(
        name: String,
        birthday: Date,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteUser(completion: @escaping (Error?) -> Void)
    
}

final class AuthenticationWorker: AuthenticationWorkerProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirebaseAuthManager.shared.signUp(email: email, password: password, completion: completion)
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirebaseAuthManager.shared.signIn(email: email, password: password, completion: completion)
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        FirebaseAuthManager.shared.signOut(completion: completion)
    }
    
    func isUserLoggedIn() -> Bool {
        FirebaseAuthManager.shared.isUserLoggedIn()
    }
    
    func isEmailVerified() -> Bool {
        return FirebaseAuthManager.shared.isEmailVerified()
    }
    
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {
        FirebaseAuthManager.shared.sendVerificationEmail(completion: completion)
    }
    
    func reloadUser(completion: @escaping (Error?) -> Void) {
        FirebaseAuthManager.shared.reloadUser(completion: completion)
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        FirebaseAuthManager.shared.deleteUser(completion: completion)
    }
    
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        FirebaseAuthManager.shared.resetPassword(email: email) { error in
            completion(error)
        }
    }
    
    func saveUserProfile(
        name: String,
        birthday: Date,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = FirebaseAuthManager.shared.getCurrentUID() else {
            return completion(.failure(
                NSError(domain: "CreateProfile", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            ))
        }
        let data: [String: Any] = [
            "name": name,
            "birthday": birthday
        ]
        FirestoreManager.shared.setDocument(
            at: "users/\(uid)",
            data: data,
            merge: true,
            completion: completion
        )
    }
    
}
