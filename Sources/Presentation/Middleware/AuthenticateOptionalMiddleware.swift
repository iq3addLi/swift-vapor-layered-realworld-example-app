//
//  AuthenticateOptionalMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Domain
import Vapor

/// Middleware to processes where authentication is optional
struct AuthenticateOptionalMiddleware: Middleware {

    let useCase = AuthenticateMiddlewareUseCase()

    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        var payload: SessionPayload?
        let token = request.http.headers.tokenAuthorization?.token
        if let token = token {
            payload = try useCase.payload(by: token)
        }

        // Write relay service value
        let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
        entity.id = payload?.id
        entity.username = payload?.username
        entity.token = token

        return try next.respond(to: request)
    }
}
