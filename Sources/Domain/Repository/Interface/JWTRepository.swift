//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

/// Repository that defines the processing to JWT.
protocol JWTRepository: Repository {

    // MARK: Functions
    
    /// JWTRepository must implement JWT issuing.
    /// - Parameters:
    ///   - id: Id of the user whose password has been verified.
    ///   - username: Name of the user whose password has been verified.
    /// - throws:
    ///    <#Description#> 
    /// - returns:
    ///    <#Description#>
    func issueJWT( id: Int, username: String ) throws -> String

    /// JWTRepository must implement JWT verify.
    /// - Parameter token: string of JWT.
    /// - returns:
    ///    <#Description#>
    /// - throws:
    ///  An error is thrown in the following cases:
    /// * Deployment failed because the secret is incorrect.
    /// * JWT has expired.
    func verifyJWT( token: String ) throws -> SessionPayload
}
