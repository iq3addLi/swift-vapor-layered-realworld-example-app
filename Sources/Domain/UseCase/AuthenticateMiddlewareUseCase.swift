//
//  AuthenticateMiddlewareUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//


import Infrastructure

public struct AuthenticateMiddlewareUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    private let jwt: JWTRepository = JWTWithVaporRepository()
    
    public init(){}
    
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWTToken(token: token)
    }
}

import Async
extension AuthenticateMiddlewareUseCase {
    
    public func user(by token: String ) throws -> Future<(Int, User)> {
        
        // Verify and expand payload
        let payload = try jwt.verifyJWTToken(token: token)
        
        // Search user in storage
        return conduit.searchUser(id: payload.id)
    }
}
