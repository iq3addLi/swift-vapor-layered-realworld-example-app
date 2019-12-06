//
//  AuthenticateRequireMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Domain
import Vapor

/// Middleware to process that requires authentication and ask for relay of authenticated user information
struct AuthenticateThenSearchUserMiddleware: Middleware {

    // MARK: Properties
    
    /// The use case for authentication.
    ///
    /// See `AuthenticateMiddlewareUseCase`.
    let useCase = AuthenticateMiddlewareUseCase()

    
    // MARK: Implementation as a Middleware
    
    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - next: <#next description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let token = request.http.headers.tokenAuthorization?.token else {
            throw Abort( .badRequest )
        }

        // Verify then search user
        return try useCase.user(by: token)
            .flatMap { tuple in
                let (id, user) = tuple

                // Add ralay service value
                let relay = (try request.privateContainer.make(VerifiedUser.self))
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
