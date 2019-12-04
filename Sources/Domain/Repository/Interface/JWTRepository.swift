//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

/// Repository that defines the processing to JWT
protocol JWTRepository: Repository {

    // MARK: Functions
    
    /// JWTRepository must implement JWT issuing.
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - username: <#username description#>
    func issueJWT( id: Int, username: String ) throws -> String

    /// JWTRepository must implement JWT verify.
    /// - Parameter token: <#token description#>
    /// - returns:
    ///    <#Description#>
    func verifyJWT( token: String ) throws -> SessionPayload
}
