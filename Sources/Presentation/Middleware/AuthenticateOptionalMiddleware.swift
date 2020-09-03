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

    // MARK: Properties
    
    /// The use case for authentication.
    ///
    /// See `AuthenticateMiddlewareUseCase`.
    let useCase = AuthenticateMiddlewareUseCase()
    
    
    // MARK: Implementation as a Middleware
    
    /// Relay the result of deploying JWT to the controller using Service.
    ///
    /// No error is thrown if JWT verify fails. Service is empty.
    /// - Parameters:
    ///   - request: See `Vapor.Request`.
    ///   - next: A next responder. See `Responder`.   
    /// - throws:
    ///    When JWT is sent but verification fails.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        // Get Authentication: Token *
        let token = request.headers.tokenAuthorization?.token
        guard let jwt = token else{
            return next.respond(to: request)
        }
        
        // Verify then expand payload
        let payload: SessionPayload
        do {
            payload = try useCase.payload(by: jwt)
        }catch{
            return request.eventLoop.makeFailedFuture(Error("failed"))
        }
        
        // stored relay service value
        request.storage[VerifiedUserEntity.Key] = VerifiedUserEntity(id: payload.id, username: payload.username, token: token)

        return next.respond(to: request)
    }
}
