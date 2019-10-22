//
//  AuthenticateOptionalMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Vapor
import Domain

final class AuthenticateOptionalMiddleware: Middleware {
    
    let useCase = AuthenticateMiddlewareUseCase()
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let auth = request.http.headers.tokenAuthorization else{
            // Clear service value to next
            let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
            entity.id = nil
            entity.username = nil
            entity.token = nil
            return try next.respond(to: request)
        }
        
        // Verify then expand payload
        let payload = try useCase.payload(by: auth.token)
        
        // Add ralay service value
        let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
        entity.id = payload.id
        entity.username = payload.username
        entity.token = auth.token
        
        return try next.respond(to: request)
    }
}
