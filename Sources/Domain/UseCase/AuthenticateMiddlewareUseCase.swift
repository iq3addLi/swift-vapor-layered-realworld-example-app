//
//  AuthenticateMiddlewareUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//


import Infrastructure

/// dummy comment
public struct AuthenticateMiddlewareUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    private let jwt: JWTRepository = JWTWithVaporRepository()
    
    /// dummy comment
    public init(){}
    
    /// dummy comment
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWTToken(token: token)
    }
}

import Async
extension AuthenticateMiddlewareUseCase {
    
    /// dummy comment
    public func user(by token: String ) throws -> Future<(Int, User)> {
        
        // Verify and expand payload
        let payload = try jwt.verifyJWTToken(token: token)
        
        // Search user in storage
        return conduit.searchUser(id: payload.id)
    }
}
