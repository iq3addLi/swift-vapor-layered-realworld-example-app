//
//  JWTWithVaporRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import Foundation
import JWTKit

/// JWTRepository implemented in vapor/jwt-kit.
struct JWTWithVaporRepository: JWTRepository {

    // MARK: Properties
    
    /// A secret
    let secret: String
    
    /// Default initializer.
    public init(){
        guard let secret = ProcessInfo.processInfo.environment["SECRET_FOR_JWT"] else {
            fatalError("'SECRET_FOR_JWT' must be set as an environment variable to start the application.")
        }
        self.secret = secret
    }

    // MARK: Functions
    
    /// Issue a JWT.
    /// - Parameters:
    ///   - id: Id of the user whose password has been verified.
    ///   - username: Name of the user whose password has been verified.
    /// - throws:
    ///    See `JWT.init(payload:)` and `JWT.sign(using:)`.
    /// - returns:
    ///    JWT as `String`.
    func issueJWT( id: Int, username: String ) throws -> String {
        // create payload
        let payload = SessionPayload(id: id, username: username, expireAfterSec: 60 * 60 * 24)
        // create JWT and sign
        let token = try JWTSigner.hs256(key: secret.bytes).sign(payload)
        
        return token
    }

    /// verify a JWT.
    /// - Parameter token: string of JWT.
    /// - throws:
    ///    See `JWT.init(from:verifiedUsing:)`.
    /// - returns:
    ///    A payload section of JWT as `SessionPayload`.
    func verifyJWT( token: String ) throws -> SessionPayload {
        // Verify and expand
        return try JWTSigner.hs256(key: secret.bytes).verify(token, as: SessionPayload.self)
    }
}
