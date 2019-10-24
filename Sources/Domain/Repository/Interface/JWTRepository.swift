//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import Foundation

protocol JWTRepository{
    
    func issuedJWTToken( id: Int, username: String ) throws -> String
    func verifyJWTToken( token: String ) throws -> SessionPayload
}
