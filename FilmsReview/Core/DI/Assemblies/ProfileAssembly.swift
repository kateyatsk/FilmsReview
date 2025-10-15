//
//
//  ProfileAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 3.09.25.
//
//

import Swinject

final class ProfileAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ProfileWorkerProtocol.self) { _ in ProfileWorker() }
            .inObjectScope(.graph)

        container.register(ProfileInteractor.self) { r in
            guard let worker = r.resolve(ProfileWorkerProtocol.self) else { fatalError("ProfileWorker not registered") }
            return ProfileInteractor(worker: worker)
        }
        .inObjectScope(.graph)

        container.register(ProfilePresenter.self) { _ in ProfilePresenter() }
            .inObjectScope(.graph)

        container.register(ProfileRouter.self) { _ in ProfileRouter() }
            .inObjectScope(.container)

        container.register(ProfileViewController.self) { r in
            let vc = ProfileViewController()
            guard
                let interactor = r.resolve(ProfileInteractor.self),
                let presenter  = r.resolve(ProfilePresenter.self),
                let router = r.resolve(ProfileRouter.self)
            else { fatalError("Profile scene not fully registered") }

            presenter.viewController = vc
            interactor.presenter = presenter
            vc.interactor = interactor

            router.viewController = vc
            vc.router = router

            return vc
        }
        .inObjectScope(.graph)
    }
}
