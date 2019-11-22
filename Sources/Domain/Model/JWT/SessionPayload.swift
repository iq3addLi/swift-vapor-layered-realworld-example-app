//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//


/// dummy comment
public struct SessionPayload{
    
    /// dummy comment
    public let id: Int
    
    /// dummy comment
    public let username: String
    
    /// dummy comment
    public let exp: ExpirationClaim
    
    /// dummy comment
    public init(id: Int, username: String, expireAfterSec exp: Int){
        self.id = id
        self.username = username
        self.exp =  ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp)))
    }
}

import JWT
extension SessionPayload: JWTPayload{
    /// dummy comment
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
