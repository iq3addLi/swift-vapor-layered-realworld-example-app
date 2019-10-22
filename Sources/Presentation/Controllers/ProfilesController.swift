//
//  ProfilesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct ProfilesController {
    
    let useCase = ProfilesUseCase()
    
    // GET /profiles/{{USERNAME}}
    // Auth optional
    func getProfile(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id // Optional
        
        // Into domain logic
        let response = try useCase.profile(by: username, readingUserId: userId)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // POST /profiles/{{USERNAME}}/follow
    // Auth then expand payload
    func follow(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Required
        
        // Into domain logic
        let response = try useCase.follow(to: username, from: userId)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // DELETE /profiles/{{USERNAME}}/follow
    // Auth then expand payload
    func unfollow(_ request: Request) throws -> Future<Response> {
        // Get parameter by URL
        let username = try request.parameters.next(String.self)
        
        // Get relayed parameter
        let userId = (try request.privateContainer.make(VerifiedUserEntity.self)).id! // Required
        
        // Into domain logic
        let response = try useCase.unfollow(to: username, from: userId)
        
        // Success
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
}
