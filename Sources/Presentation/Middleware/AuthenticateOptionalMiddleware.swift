//
//  AuthenticateOptionalMiddleware.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/10/07.
//

import Vapor

final class AuthenticateOptionalMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Get Authentication: Token *
        guard let _ = request.http.headers.tokenAuthorization else{
            // Authentication skipped
            return try next.respond(to: request)
        }
        
        // Authentication passed
        return try next.respond(to: request)
    }
}
