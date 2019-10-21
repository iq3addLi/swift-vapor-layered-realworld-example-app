//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//


import JWT

public final class SessionPayload{
    public var id: Int?
    public var username: String?
    public var exp: ExpirationClaim?
    public var token: String?
    
    public init(id: Int? = nil, username: String? = nil, expireAfterSec exp: Int? = nil, token: String? = nil ){
        self.id = id
        self.username = username
        self.exp = exp != nil ? ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp!))) : nil
        self.token =  token
    }
}

extension SessionPayload: JWTPayload{
    public func verify(using signer: JWTSigner) throws {
        guard let exp = self.exp else{
            throw Error(reason: "ExpirationClaim is empty")
        }
        try exp.verifyNotExpired()
    }
}

import Vapor
extension SessionPayload: Service{} // MEMO: struct is can't be Service
