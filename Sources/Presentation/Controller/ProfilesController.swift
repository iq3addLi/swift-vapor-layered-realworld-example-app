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

    private let useCase = ProfilesUseCase()

    // GET /profiles/{{USERNAME}}
    // Auth optional
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

    // POST /profiles/{{USERNAME}}/follow
    // Auth then expand payload
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

    // DELETE /profiles/{{USERNAME}}/follow
    // Auth then expand payload
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
