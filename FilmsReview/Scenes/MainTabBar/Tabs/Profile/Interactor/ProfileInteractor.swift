//
//  
//  ProfileInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol ProfileInteractorProtocol: InteractorProtocol {
    func load()
    func logout()
}

final class ProfileInteractor: ProfileInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    private let worker: ProfileWorkerProtocol

    init(worker: ProfileWorkerProtocol) { self.worker = worker }

    func load() {
        Task {
            await MainActor.run { (presenter as? ProfilePresenterProtocol)?.presentLoading(true) }
            let resp = await worker.loadProfile()
            await MainActor.run {
                (presenter as? ProfilePresenterProtocol)?.present(data: resp)
                (presenter as? ProfilePresenterProtocol)?.presentLoading(false)
            }
        }
    }

    func logout() {
        Task {
            await MainActor.run { (presenter as? ProfilePresenterProtocol)?.presentLoading(true) }
            do {
                try await worker.signOut()
                await MainActor.run {
                    (presenter as? ProfilePresenterProtocol)?.presentLoggedOut()
                    (presenter as? ProfilePresenterProtocol)?.presentLoading(false)
                }
            } catch {
                await MainActor.run {
                    (presenter as? ProfilePresenterProtocol)?.present(error: error)
                    (presenter as? ProfilePresenterProtocol)?.presentLoading(false)
                }
            }
        }
    }

    
}
