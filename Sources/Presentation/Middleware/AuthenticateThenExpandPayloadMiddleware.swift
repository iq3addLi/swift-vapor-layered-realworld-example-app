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
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Get Authentication: Token *
        guard let token = request.headers.tokenAuthorization?.token else {
            return request.eventLoop.makeFailedFuture(Error("failed"))
        }

        // Verify then expand payload
        let payload: SessionPayload
        do {
            payload = try useCase.payload(by: token)
        }catch{
            return request.eventLoop.makeFailedFuture(Error("failed"))
        }

        // stored relay service value
        request.storage[VerifiedUserEntity.Key] = VerifiedUserEntity(id: payload.id, username: payload.username, token: token)
        
        return next.respond(to: request)
    }
}
