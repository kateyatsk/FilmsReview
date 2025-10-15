//
//  DependencyContainer.swift
//  FilmsReview
//
//  Created by Alex Mialeshka on 25/06/2025.
//

import Swinject

class DependencyContainer {
    static let shared = DependencyContainer()
    let container: Container

    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        let assembler = Assembler([
            CoreAssembly(),
            OnboardingAssembly(),
            AuthenticationAssembly(),
            HomeAssembly(),
            ProfileAssembly(),
            FavoriteAssembly(),
            SearchAssembly(),
            MainAssembly()
        ], container: container)
    }
}
