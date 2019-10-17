//
//  AuthenticateRequireMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Vapor
import Domain

struct AuthenticateThenSearchUserMiddleware: Middleware {
    
    let useCase = AuthenticateMiddlewareUseCase()
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let auth = request.http.headers.tokenAuthorization else{
            // Abort
            throw Abort( .badRequest )
        }
        
        // Verify then search user
        guard let (id, user) = try useCase.user(by: auth.token) else{
            // Abort
            throw Abort( .internalServerError )
        }
        
        // Add ralay service value
        let relay = (try request.privateContainer.make(AuthedUser.self))
        relay.id = id
        relay.email = user.email
        relay.username = user.username
        relay.token = auth.token
        relay.bio = user.bio
        relay.image = user.image
        
        return try next.respond(to: request)
    }
}
