//
//  JWTWithVaporRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import JWT

/// JWTRepository implemented in vapor/jwt-kit.
struct JWTWithVaporRepository: JWTRepository {

    // MARK: Properties
    
    /// A secret
    let secret = "secret" // TODO: Prepare a changeable function

    // MARK: Functions
    
    /// Issue a JWT.
    /// - Parameters:
    ///   - id: Id of the user whose password has been verified.
    ///   - username: Name of the user whose password has been verified.
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#> 
    func issueJWT( id: Int, username: String ) throws -> String {

        // create payload
        let payload = SessionPayload(id: id, username: username, expireAfterSec: 60 * 60 * 24)

        // create JWT and sign
        let data = try JWT(payload: payload).sign(using: .hs256(key: secret))

        // Encoding to string and return
        guard let token =  String(data: data, encoding: .utf8) else {
            throw Error("JWT crypted data is encoding failed.")
        }
        return token
    }

    /// verify a JWT.
    /// - Parameter token: string of JWT.
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func verifyJWT( token: String ) throws -> SessionPayload {
        // Verify and expand
        return try JWT<SessionPayload>(from: token, verifiedUsing: .hs256(key: secret)).payload
    }
}
