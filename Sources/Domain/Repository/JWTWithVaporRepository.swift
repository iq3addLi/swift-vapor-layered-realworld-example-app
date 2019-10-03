//
//  JWTWithVaporRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import JWT

public struct JWTWithVaporRepository: JWTRepository{
    
    func issuedJWTToken( id: Int, username: String ) throws -> String{
        
        // create payload
        let payload = SessionPayload(id: id, username: username, expireAfterSec: 60)
        
        // create JWT and sign
        let data = try JWT(payload: payload).sign(using: .hs256(key: "secret"))
        
        // Encoding to string and return
        guard let token =  String(data: data, encoding: .utf8) else{
            fatalError("JWT crypted data is encoding failed.")
        }
        return token
    }
}

