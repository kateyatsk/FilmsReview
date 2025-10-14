//
//  
//  ProfilePresenter.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import UIKit

protocol ProfilePresenterProtocol: PresenterProtocol {
    func presentLoading(_ isLoading: Bool)
    func present(data: Profile.Load.Response)
    func present(error: Error)
    func presentLoggedOut()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    private enum Constants {
        enum Labels {
            static let unknown = "—"
        }
        enum DateFmt {
            static let format = "MMM d, yyyy"
            static let locale = Locale(identifier: "en_US_POSIX")
        }
    }

    weak var viewController: ViewControllerProtocol?

    func presentLoading(_ isLoading: Bool) {
        (viewController as? ProfileViewProtocol)?.displayLoading(isLoading)
    }

    func present(data: Profile.Load.Response) {
        let birthdayText: String = {
            guard let d = data.birthday else { return Constants.Labels.unknown }
            let df = DateFormatter()
            df.locale = Constants.DateFmt.locale
            df.dateFormat = Constants.DateFmt.format
            return df.string(from: d)
        }()

        let vm = Profile.Load.ViewModel(
            name: data.name,
            nameValue: data.name.isEmpty ? Constants.Labels.unknown : data.name,
            emailValue: data.email.isEmpty ? Constants.Labels.unknown : data.email,
            genresValue: data.genresText.isEmpty ? Constants.Labels.unknown : data.genresText,
            birthdayValue: birthdayText,
            avatar: data.avatar
        )

        (viewController as? ProfileViewProtocol)?.displayProfile(vm)
    }

    func present(error: Error) {
        (viewController as? ProfileViewProtocol)?.displayError(error.localizedDescription)
    }

    func presentLoggedOut() {
        (viewController as? ProfileViewProtocol)?.displayLoggedOut()
    }
}
