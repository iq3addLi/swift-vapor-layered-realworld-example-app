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
    
    /// GET /profiles/{{USERNAME}}
    ///
    /// Auth optional
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getProfile(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional

        // Into domain logic
        return useCase.profile(by: username, readingUserId: userId)
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// POST /profiles/{{USERNAME}}/follow
    ///
    /// Auth then expand payload.
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func follow(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Require

        // Into domain logic
        return useCase.follow(to: username, from: userId)
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// DELETE /profiles/{{USERNAME}}/follow
    ///
    /// Auth then expand payload.
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func unfollow(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Require

        // Into domain logic
        return useCase.unfollow(to: username, from: userId)
            .map { response in
                request.response( response, as: .json)
            }
    }
}
