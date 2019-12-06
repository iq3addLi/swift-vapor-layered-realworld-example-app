//
//  Session.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

/// The payload part of JWT.
public struct SessionPayload {

    // MARK: Properties
    
    /// Issuer id.
    public let id: Int

    /// Issuer username.
    public let username: String

    /// JWT expiration date.
    public let exp: ExpirationClaim

    // MARK: Initializer
    
    /// Default initializer.
    /// - Parameters:
    ///   - id: Issuer id.
    ///   - username: Issuer username.
    ///   - exp: JWT expiration date.
    public init(id: Int, username: String, expireAfterSec exp: Int) {
        self.id = id
        self.username = username
        self.exp =  ExpirationClaim(value: Date().addingTimeInterval(TimeInterval(exp)))
    }
}


import JWT

// MARK: Implementation as JWTPayload
extension SessionPayload: JWTPayload {

    /// JWT is verified using the vapor/jwt-kit function.
    /// - Parameter signer: See `JWTPayload`.
    /// - throws:
    ///    See `ExpirationClaim.verifyNotExpired()`.
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
