//
//  AuthenticateThenExpandPayloadMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Vapor
import Domain

struct AuthenticateThenExpandPayloadMiddleware: Middleware {

    let useCase = AuthenticateMiddlewareUseCase()

    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let token = request.http.headers.tokenAuthorization?.token else {
            // Abort
            throw Abort( .badRequest )
        }

        // Verify then expand payload
        let payload = try useCase.payload(by: token)

        // Add ralay service value
        let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
        entity.id = payload.id
        entity.username = payload.username
        entity.token = token

        return try next.respond(to: request)
    }
}
