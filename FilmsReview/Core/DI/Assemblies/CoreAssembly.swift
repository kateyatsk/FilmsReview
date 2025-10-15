//
//  CoreAssembly.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 12.10.25.
//

import Swinject

class CoreAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(APIConfig.self) { _ in
            do { return try APIConfig.tmdbFromPlist() }
            catch { fatalError("APIConfig.tmdbFromPlist failed: \(error)") }
        }
        .inObjectScope(.container)
        
        container.register(APIClient.self) { resolver in
            guard let configuration = resolver.resolve(APIConfig.self) else {
                fatalError("APIConfig not registered")
            }
            return APIClient(config: configuration)
        }
        .inObjectScope(.container)
        
        container.register(TMDBServiceProtocol.self) { resolver in
            guard let client = resolver.resolve(APIClient.self) else {
                fatalError("APIClient not registered")
            }
            return TMDBService(client: client)
        }
        .inObjectScope(.container)
        
        container.register(CloudinaryManaging.self) { _ in
            CloudinaryManager()
        }.inObjectScope(.container)
        
        container.register(ImageLoaderProtocol.self) { _ in
            ImageLoader()
        }.inObjectScope(.container)
        
    }
}

