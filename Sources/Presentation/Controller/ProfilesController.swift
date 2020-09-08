//
//  ProfilesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain
import Vapor

/// Controller For Profile processing
struct ProfilesController {

    // MARK: Properties
    
    /// The use case for profiles.
    ///
    /// See `ProfilesUseCase`.
    private let useCase = ProfilesUseCase()

    
    // MARK: Controller for profiles
    
    /// GET /profiles/:username
    ///
    /// Auth optional
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getProfile(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        guard let username = request.parameters.get("username") else{
            fatalError("URL parameters contains mistake.")
        }
        
        // Get relayed parameter
        let userId = request.storage[VerifiedUserEntity.Key.self]?.id // Optional

        // Into domain logic
        return useCase.profile(by: username, readingUserId: userId)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// POST /profiles/:username/follow
    ///
    /// Auth then expand payload.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func follow(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        guard let username = request.parameters.get("username") else{
            fatalError("URL parameters contains mistake.")
        }
        
        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.") // Require
        }

        // Into domain logic
        return useCase.follow(to: username, from: userId)
            .flatMapThrowing { response in
                try Response( response )
            }
    }

    /// DELETE /profiles/:username/follow
    ///
    /// Auth then expand payload.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    When URL parameters cannot be obtained with the expected type.
    /// - returns:
    ///    The `Future` that returns `Response`. 
    func unfollow(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        guard let username = request.parameters.get("username") else{
            fatalError("URL parameters contains mistake.")
        }
        
        // Get relayed parameter
        guard let userId = request.storage[VerifiedUserEntity.Key.self]?.id else {
            fatalError("Middleware not passed authenticated user.") // Require
        }

        // Into domain logic
        return useCase.unfollow(to: username, from: userId)
            .flatMapThrowing { response in
                try Response( response )
            }
    }
}
