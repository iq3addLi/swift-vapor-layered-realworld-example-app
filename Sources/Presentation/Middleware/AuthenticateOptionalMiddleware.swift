//
//  AuthenticateOptionalMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Vapor
import Domain


struct AuthenticateOptionalMiddleware: Middleware {
    
    let useCase = AuthenticateMiddlewareUseCase()
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        let token = request.http.headers.tokenAuthorization?.token
        try { ( payload: SessionPayload? ) throws in
            // Write/erase ralay service value
            let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
            entity.id = payload?.id
            entity.username = payload?.username
            entity.token = token
        }( token == nil ? nil : (try useCase.payload(by: token!)) )
        return try next.respond(to: request)
    }
}
