//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

/// Repository that defines the processing to JWT
protocol JWTRepository: Repository {

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter username: <#username description#>
    /// - returns:
    ///    <#Description#>  
    func issueJWT( id: Int, username: String ) throws -> String

    /// <#Description#>
    /// - Parameter token: <#token description#>
    /// - returns:
    ///    <#Description#>
    func verifyJWT( token: String ) throws -> SessionPayload
}
