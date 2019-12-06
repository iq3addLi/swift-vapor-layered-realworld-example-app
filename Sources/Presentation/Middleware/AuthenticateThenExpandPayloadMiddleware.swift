//
//  AuthenticateThenExpandPayloadMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Domain
import Vapor

/// Middleware to processes that requires authentication and ask for JWT Payload Relay
struct AuthenticateThenExpandPayloadMiddleware: Middleware {

    // MARK: Properties
    
    /// The use case for authentication.
    ///
    /// See `AuthenticateMiddlewareUseCase`.
    let useCase = AuthenticateMiddlewareUseCase()

    
    // MARK: Implementation as a Middleware
    
    /// Middleware processing.
    /// - Parameters:
    ///   - request: See `Vapor.Request`.
    ///   - next: A next responder. See `Responder`.
    /// - throws:
    ///    Error is thrown in the following cases.
    ///    * HTTPHeader has no Authorization.
    ///    * JWT validation fails.
    /// - returns:
    ///    The `Future` that returns `Response`. 
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let token = request.http.headers.tokenAuthorization?.token else {
            throw Abort( .badRequest )
        }

        // Verify then expand payload
        let payload = try useCase.payload(by: token)

        // Add relay service value
        let entity = (try request.privateContainer.make(VerifiedUserEntity.self))
        entity.id = payload.id
        entity.username = payload.username
        entity.token = token

        return try next.respond(to: request)
    }
}
