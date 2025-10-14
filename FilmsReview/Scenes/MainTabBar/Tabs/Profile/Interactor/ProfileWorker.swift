//
//  
//  ProfileWorker.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit
import FirebaseAuth

protocol ProfileWorkerProtocol {
    func loadProfile() async -> Profile.Load.Response
    func signOut() async throws
}

final class ProfileWorker: ProfileWorkerProtocol {

    func loadProfile() async -> Profile.Load.Response {
        guard let uid = FirebaseAuthManager.shared.getCurrentUID() else {
            return .init(name: "Guest",
                         email: "—",
                         genresText: "—",
                         birthday: nil,
                         avatar: nil)
        }

        let profile = await FirestoreManager.shared.fetchUserProfile(uid: uid)

        let fsName = (profile?.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = !fsName.isEmpty
            ? fsName
            : (Auth.auth().currentUser?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        let name = !displayName.isEmpty
            ? displayName
            : "-"

        let email = (profile?.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let finalEmail = !email.isEmpty
            ? email
            : (Auth.auth().currentUser?.email ?? "—")

        let genres = (profile?.favoriteGenres ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let genresText = genres.isEmpty ? "—" : genres.joined(separator: ", ")

        let birthday: Date? = {
            guard let d = profile?.birthday, d.timeIntervalSince1970 > 0 else { return nil }
            return d
        }()

        let avatarURL = profile?.avatarURL ?? Auth.auth().currentUser?.photoURL
        let avatar = await loadImage(from: avatarURL)

        return .init(name: name,
                     email: finalEmail,
                     genresText: genresText,
                     birthday: birthday,
                     avatar: avatar)
    }

    func signOut() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            FirebaseAuthManager.shared.signOut { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func loadImage(from url: URL?) async -> UIImage? {
        guard let url else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
