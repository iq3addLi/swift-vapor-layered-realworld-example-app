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
    
    public func user(by token: String ) throws -> ( id: Int, user: User)? {
        
        // Verify and expand payload
        let payload = try jwt.verifyJWTToken(token: token)
        
        // Search user in storage
        let user = try conduit.searchUser(id: payload.id)
        
        return ( payload.id, user )
    }
    
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWTToken(token: token)
    }
}
