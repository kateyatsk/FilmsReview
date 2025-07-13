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
       func signOut()
       func isUserLoggedIn() -> Bool
}

final class AuthenticationWorker: AuthenticationWorkerProtocol {
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
         FirebaseAuthManager.shared.signUp(email: email, password: password, completion: completion)
     }

     func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
         FirebaseAuthManager.shared.signIn(email: email, password: password, completion: completion)
     }

     func signOut() {
         FirebaseAuthManager.shared.signOut()
     }

     func isUserLoggedIn() -> Bool {
         FirebaseAuthManager.shared.isUserLoggedIn()
     }
}
