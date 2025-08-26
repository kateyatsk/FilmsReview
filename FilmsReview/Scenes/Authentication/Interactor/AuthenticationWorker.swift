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
    func deleteUser(completion: @escaping (Error?) -> Void)
    
    func getCurrentUserEmail() -> String?
    func getCurrentUserID() -> String?
    
    func uploadAvatar(data: Data?, userId: String, completion: @escaping (Result<URL?, Error>) -> Void)
    func saveUserProfileToFirestore(
        uid: String,
        email: String,
        name: String,
        birthday: Date,
        avatarURL: URL?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class AuthenticationWorker: AuthenticationWorkerProtocol {
    private let cloudinary: CloudinaryManaging
    
    init(
        cloudinary: CloudinaryManaging
    ) {
        self.cloudinary = cloudinary
    }
    
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
    
    func getCurrentUserEmail() -> String? {
        FirebaseAuthManager.shared.getCurrentUserEmail()
    }
    
    func getCurrentUserID() -> String? {
        FirebaseAuthManager.shared.getCurrentUID()
    }
    
    func uploadAvatar(data: Data?, userId: String, completion: @escaping (Result<URL?, Error>) -> Void) {
        guard let data = data else {
            completion(.success(nil))
            return
        }
        
        cloudinary.upload(data: data, userId: userId) { result in
            completion(result.map { Optional.some($0) })
        }
    }
    
    func saveUserProfileToFirestore(
        uid: String,
        email: String,
        name: String,
        birthday: Date,
        avatarURL: URL?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let profile = UserProfile(uid: uid, email: email, name: name, birthday: birthday, avatarURL: avatarURL)
        
        do {
            let data = try JSONEncoder().encode(profile)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NSError(domain: "Serialization", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode profile"])
            }
            
            FirestoreManager.shared.setDocument(
                at: "users/\(uid)",
                data: dict,
                merge: true,
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }
    
}
