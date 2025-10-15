//
//
//  HomePresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol HomePresenterProtocol: PresenterProtocol {
    func presentContent(response: HomeModels.ViewModel)
    func presentError(error: Error)
    func presentPaginated(items: [MediaItem])
    func presentHeader(name: String, avatar: UIImage?)
}

final class HomePresenter: HomePresenterProtocol {
    weak var viewController: ViewControllerProtocol?
    
    func presentContent(response: HomeModels.ViewModel) {
        (viewController as? HomeVCProtocol)?.displayContent(viewModel: response)
    }
    
    func presentError(error: Error) {
        (viewController as? HomeVCProtocol)?.displayError(error: error)
    }
    
    func presentHeader(name: String, avatar: UIImage?) {
        (viewController as? HomeVCProtocol)?.updateHeader(name: name, avatar: avatar)
    }
    
    func presentPaginated(items: [MediaItem]) {
        (viewController as? MediaListVCProtocol)?.displayContent(viewModel: items)
    }

}
