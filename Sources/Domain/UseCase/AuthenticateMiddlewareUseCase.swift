//
//  AuthenticateMiddlewareUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//

/// Use cases for authentication middlewares
public struct AuthenticateMiddlewareUseCase: UseCase {
    
    // MARK: Properties
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    private let jwt: JWTRepository = JWTWithVaporRepository()

    // MARK: Functions
    
    /// <#Description#>
    public init() {}

    /// <#Description#>
    /// - parameters:
    ///     - token: <#token description#>
    /// - returns:
    ///    <#Description#>
    /// - throws:
    ///  <#Description#>
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWT(token: token)
    }
    
    
    /// <#Description#>
    /// - parameters:
    ///     - token: <#token description#>
    /// - returns:
    ///    <#Description#>
    /// - throws:
    ///  <#Description#> 
    public func user(by token: String ) throws -> Future<(Int, User)> {

        // Verify and expand payload
        let payload = try jwt.verifyJWT(token: token)

        // Search user in storage
        return conduit.searchUser(id: payload.id)
    }
}
