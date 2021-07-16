//
//  JWTRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/03.
//

/// Repository that defines the processing to JSONWebToken.
protocol JWTRepository: Repository {

    // MARK: Functions
    
    /// JWTRepository must implement JWT issuing.
    /// - Parameters:
    ///   - id: Id of the user whose password has been verified.
    ///   - username: Name of the user whose password has been verified.
    /// - throws:
    ///    It's assumed that an error will be thrown when PWT is issued.
    /// - returns:
    ///    Expected to return the issued JWT as `String`.
    func issueJWT( id: Int, username: String ) throws -> String

    /// JWTRepository must implement JWT verify.
    /// - Parameter token: string of JWT.
    /// - throws:
    ///    It is assumed that Error will be thrown when validation fails.
    /// - returns:
    ///    Expected to return JWT payload section as `SessionPayload` after validation processing.
    func verifyJWT( token: String ) throws -> SessionPayload
}
