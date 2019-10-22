//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//


public struct SessionPayload{
    public let id: Int
    public let username: String
    public let exp: ExpirationClaim
    
    public init(id: Int, username: String, expireAfterSec exp: Int){
        self.id = id
        self.username = username
        self.exp =  ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp)))
    }
}

import JWT
extension SessionPayload: JWTPayload{
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
