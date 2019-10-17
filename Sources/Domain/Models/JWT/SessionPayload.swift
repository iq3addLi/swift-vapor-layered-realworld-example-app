//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//


import JWT

public final class SessionPayload{
    public var id: Int
    public var username: String
    public var exp: ExpirationClaim
    public var token: String
    
    public init(id: Int = 0, username: String = "", expireAfterSec exp: Int = 0, token: String = "" ){
        self.id = id
        self.username = username
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp)))
        self.token =  token
    }
}

extension SessionPayload: JWTPayload{
    public func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

import Vapor
extension SessionPayload: Service{} // MEMO: struct is can't be Service
