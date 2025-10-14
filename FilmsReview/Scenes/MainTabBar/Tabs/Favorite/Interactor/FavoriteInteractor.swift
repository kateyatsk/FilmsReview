//
//  
//  FavoriteInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol FavoriteInteractorProtocol: InteractorProtocol {
    func load(uid: String)
    func toggle(item: MediaItem, isFavorite: Bool, uid: String)
}

final class FavoriteInteractor: FavoriteInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    let worker: FavoriteWorkerProtocol

    init(presenter: FavoritePresenter? = nil, worker: FavoriteWorkerProtocol) {
        self.presenter = presenter
        self.worker = worker
    }

    func load(uid: String) {
        (presenter as? FavoritePresenterProtocol)?.setLoading(true)
        Task {
            do {
                let items = try await worker.loadFavorites(uid: uid)
                (presenter as? FavoritePresenterProtocol)?.present(items: items)
            } catch {
                (presenter as? FavoritePresenterProtocol)?.present(items: [])
            }
            (presenter as? FavoritePresenterProtocol)?.setLoading(false)
        }
    }

    func toggle(item: MediaItem, isFavorite: Bool, uid: String) {
        Task {
            try? await worker.toggleFavorite(uid: uid, item: item, isFavorite: isFavorite)
        }
    }
}
