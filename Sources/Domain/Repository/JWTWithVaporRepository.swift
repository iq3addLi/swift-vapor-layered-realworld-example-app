//
//  JWTWithVaporRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import JWT

/// <#Description#>
struct JWTWithVaporRepository: JWTRepository {

    let secret = "secret"

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter username: <#username description#>
    func issuedJWTToken( id: Int, username: String ) throws -> String {

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

    /// <#Description#>
    /// - Parameter token: <#token description#>
    func verifyJWTToken( token: String ) throws -> SessionPayload {
        // Verify and expand
        return try JWT<SessionPayload>(from: token, verifiedUsing: .hs256(key: secret)).payload
    }
}
