//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

import Foundation


/// <#Description#>
protocol JWTRepository: Repository{
    
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter username: <#username description#>
    /// - returns:
    ///    <#Description#>  
    func issuedJWTToken( id: Int, username: String ) throws -> String
    
    
    /// <#Description#>
    /// - Parameter token: <#token description#>
    /// - returns:
    ///    <#Description#>
    func verifyJWTToken( token: String ) throws -> SessionPayload
}
