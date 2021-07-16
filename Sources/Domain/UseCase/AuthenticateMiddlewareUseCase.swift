//
//  AuthenticateMiddlewareUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/07.
//

/// Use cases for authentication middlewares.
public struct AuthenticateMiddlewareUseCase: UseCase {
    
    // MARK: Properties
    
    /// See `ConduitMySQLRepository`.
    private let conduit: ConduitRepository = ConduitMySQLRepository.shared
    
    /// See `JWTWithVaporRepository`.
    private let jwt: JWTRepository = JWTWithVaporRepository()

    
    // MARK: Initializer
    
    /// Default Initializer.
    public init() {}

    // MARK: Use cases for authentication
    
    /// This use case has work of expand payload from JWT.
    /// - parameters:
    ///     - token: Please pass in the JWT that expand payload.
    /// - throws:
    ///   See `JWTRepository.verifyJWT`.
    /// - returns:
    ///   See `SessionPayload`.
    public func payload(by token: String ) throws -> SessionPayload {
        // Verify and expand payload
        return try jwt.verifyJWT(token: token)
    }
    
    
    /// This use case has work of receiving the JWT and get `User`'s infomation.
    /// - parameters:
    ///     - token: Please pass in the JWT that expand payload.
    /// - throws:
    ///   See `JWTRepository.verifyJWT`.
    /// - returns:
    ///   The `Future` that returns `(Int, User)`. Int is `User`'s Id.
    public func user(by token: String ) throws -> Future<(Int, User)> {

        // Verify and expand payload
        let payload = try jwt.verifyJWT(token: token)

        // Search user in storage
        return conduit.searchUser(id: payload.id)
    }
}
