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
        guard let token = request.http.headers.tokenAuthorization?.token else{

            // Erase ralay service value
            let relay = (try request.privateContainer.make(AuthedUser.self))
            relay.id = 0
            relay.email = ""
            relay.username = ""
            relay.token = ""
            relay.bio = ""
            relay.image = ""
            
            // Abort
            throw Abort( .badRequest )
        }
        
        // Verify then search user
        return try useCase.user(by: token)
            .flatMap{ tuple in
                let (id, user) = tuple

                // Add ralay service value
                let relay = (try request.privateContainer.make(AuthedUser.self))
                relay.id = id
                relay.email = user.email
                relay.username = user.username
                relay.token = token
                relay.bio = user.bio
                relay.image = user.image
                
                return try next.respond(to: request)
            }
    }
}
