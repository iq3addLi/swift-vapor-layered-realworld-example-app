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
        let session = try jwt.verifyJWTToken(token: token)
        
        let userId = session.id!
        
        // Search user in storage
        let user = try conduit.searchUser(id: userId)
        
        return ( userId, user )
    }
    
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWTToken(token: token)
    }
}
