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
    
    /// Middleware processing.
    /// - Parameters:
    ///   - request: See `Vapor.Request`.
    ///   - next: A next responder. See `Responder`.   
    /// - throws:
    ///    See `Container.make()`.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Get Authentication: Token *
        guard let token = request.headers.tokenAuthorization?.token else {
            return request.eventLoop.makeFailedFuture(Error("failed"))
        }

        // Verify then search user
        do{
            return try useCase.user(by: token)
            .flatMap { id, user in

                // Add ralay service value
                request.storage[VerifiedUser.Key] = VerifiedUser(
                    id: id,
                    email: user.email,
                    token: token,
                    username: user.username,
                    bio: user.bio,
                    image: user.image
                )

                return next.respond(to: request)
            }
        }catch{
            return request.eventLoop.makeFailedFuture(Error("failed"))
        }
    }
}
