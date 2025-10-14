//
//  
//  SearchInteractor.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Foundation

protocol SearchInteractorProtocol: InteractorProtocol {
    func loadTopSearches()
    func search(query: String)
}

final class SearchInteractor: SearchInteractorProtocol {
    var presenter: (any PresenterProtocol)?
    private let worker: SearchWorkerProtocol
    private var currentSearchTask: Task<Void, Never>?

    init(worker: SearchWorkerProtocol) { self.worker = worker }

    func loadTopSearches() {
        Task {
            do {
                let items = try await worker.loadTopSearches(page: 1)
                await MainActor.run {
                    (presenter as? SearchPresenterProtocol)?.presentTop(items)
                }
            } catch {
                await MainActor.run {
                    (presenter as? SearchPresenterProtocol)?.presentError(error)
                }
            }
        }
    }

    func search(query: String) {
        currentSearchTask?.cancel()
        
        currentSearchTask = Task {
            do {
                let items = try await worker.searchItems(query: query, page: 1)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    (presenter as? SearchPresenterProtocol)?.presentResults(items)
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    (presenter as? SearchPresenterProtocol)?.presentError(error)
                }
            }
        }
    }
}

