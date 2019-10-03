//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//


import JWT

final class SessionPayload{
    var id: Int
    var username: String
    var exp: ExpirationClaim
    
    init(id: Int, username: String, expireAfterSec exp: Int ){
        self.id = id
        self.username = username
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp)))
    }
}

extension SessionPayload: JWTPayload{
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

import Vapor
extension SessionPayload: Service{} // MEMO: struct is can't be Service
